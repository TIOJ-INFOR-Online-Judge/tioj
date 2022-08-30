class ContestsController < ApplicationController
  before_action :authenticate_admin!, except: [:dashboard, :dashboard_update, :index, :show]
  before_action :set_contest, only: [:show, :edit, :update, :destroy, :dashboard, :dashboard_update, :set_contest_task]
  before_action :check_started!, only: [:dashboard]
  before_action :set_tasks, only: [:show, :dashboard, :dashboard_update, :set_contest_task]
  before_action :calculate_ranking, only: [:dashboard, :dashboard_update]
  layout :set_contest_layout, only: [:show, :dashboard, :dashboard_update]
  helper_method :is_started?

  def set_contest_task
    redirect_to contest_path(@contest)
    alter_to = params[:alter_to].to_i
    name = Problem.visible_states.key(alter_to)
    flash[:notice] = "Contest tasks set to #{helpers.visible_state_desc_map[name]}."
    @tasks.map{|a| a.update(:visible_state => alter_to)}
  end

  def calculate_ranking
    if Time.now < @contest.start_time
      authenticate_admin!
    end

    c_submissions = nil
    if @contest.type_ioi? and Time.now >= @contest.start_time and Time.now <= @contest.end_time
      authenticate_user!
      if not current_user.admin?
        c_submissions = @contest.submissions.where("user_id = ?", current_user.id)
        flash[:notice] = "You can only see your own score."
      else
        c_submissions = @contest.submissions
      end
    else
      c_submissions = @contest.submissions
    end

    def Rank(a, &func)
      run = id = 0
      prv = nil
      a.map do |n|
        run += 1
        next id if prv and func[n] == func[prv]
        prv = n.clone
        id += run
        run = 0
        id
      end
    end
    @contest_submissions = c_submissions.select([:id, :problem_id, :user_id, :result, :score, :created_at]).to_a
    @submissions = @contest_submissions.group_by(&:problem_id)
    @participants = User.find(@contest_submissions.map(&:user_id).uniq)
    @submissions = @tasks.map{|x| @submissions[x.id] or []}
    first_solved = @submissions.map{|sub| sub.select{|a| a.result == 'AC'}.min_by(&:id)}.map{|a| a ? a.id : -1}
    @scores = []
    if @contest.type_acm?
      freeze_start = current_user&.admin? ? @contest.end_time : @contest.freeze_after
      @participants.each do |u|
        t = []
        total_attm = 0
        total_solv = 0
        last_ac = 0
        penalty = 0
        @submissions.zip(first_solved).each do |sub, firstsolve|
          succ = sub.select{|a| a.user_id == u.id and a.result == 'AC' and a.created_at < freeze_start}.min_by{|a| a.id}
          if succ
            attm = sub.select{|a| a.user_id == u.id and a.id < succ.id and not a.result.in? (['CE', 'ER', 'queued', 'Validating']) and a.created_at < freeze_start}.size
            tm = (succ.created_at - @contest.start_time).to_i / 60
            last_ac = [last_ac, tm].max
            t << [attm + 1, tm, succ.id == firstsolve, 0]
            total_solv += 1
            total_attm += attm + 1
            penalty += attm * 20
          else
            attm = sub.select{|a| a.user_id == u.id and not a.result.in? (['CE', 'ER', 'queued', 'Validating']) and a.created_at < freeze_start}.size
            pend = sub.select{|a| a.user_id == u.id and (a.result.in? (['queued', 'Validating']) or a.created_at >= freeze_start)}.size
            t << [attm, -1, false, pend]
            total_attm += attm
          end
        end
        @scores << [u, total_attm, total_solv, t, t.map{|a| a[1] == -1 ? 0 : a[1]}.sum + penalty, last_ac]
      end
      @scores.sort_by!{|a| [-a[2], a[4], a[5]]}
      @scores = @scores.zip(Rank(@scores){|a| [a[2], a[4], a[5]]}).map {|n| n[0] + [n[1]]}
      @color = @scores.map{|a| a[2]}.uniq.sort_by{|a| -a}
      @color << 0
      if not current_user&.admin? and Time.now >= freeze_start and @contest.freeze_minutes != 0
        flash.now[:notice] = "Scoreboard is now frozen."
      end
    else
      @participants.each do |u|
        t = []
        @submissions.each do |sub|
          if sub.select{|a| a.user_id == u.id}.empty?
            t << 0
          else
            t << sub.select{|a| a.user_id == u.id}.max_by{|a| a.score}.score
          end
        end
        @scores << [u, t, t.sum]
      end
      @scores = @scores.sort_by{|a| -a[2]}
      @scores = @scores.zip(Rank(@scores){|a| a[2]}).map {|n| n[0] + [n[1]]}
      @color = @scores.map{|a| a[2]}.uniq.sort_by{|a| -a}
      @color << 0
    end
  end

  def dashboard
  end

  def dashboard_update
    respond_to do |prefix|
      prefix.js
    end
  end

  def index
    @contests = Contest.order("id DESC").page(params[:page])
  end

  def show
  end

  def new
    @contest = Contest.new
    1.times { @contest.contest_problem_joints.build }
    @ban_compiler_ids = Set[]
  end

  def edit
    @ban_compiler_ids = @contest.compilers.map(&:id).to_set
  end

  def create
    params[:contest][:compiler_ids] ||= []
    @contest = Contest.new(contest_params)
    respond_to do |format|
      if !check_tasks?
        format.html { render action: 'new' }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      elsif @contest.save
        format.html { redirect_to @contest, notice: 'Contest was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contest }
      else
        format.html { render action: 'new' }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params[:contest][:compiler_ids] ||= []
    respond_to do |format|
      if !check_tasks?
        format.html { render action: 'new' }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      elsif @contest.update(contest_params)
        format.html { redirect_to @contest, notice: 'Contest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contest.destroy
    respond_to do |format|
      format.html { redirect_to contests_url }
      format.json { head :no_content }
    end
  end

  private
  def set_contest
    @contest = Contest.find(params[:id])
  end

  def set_tasks
    @tasks = @contest.contest_problem_joints.order("id ASC").includes(:problem).map{|e| e.problem}
  end

  def check_tasks?
    def l_check(val)
      unless Problem.exists?(val['problem_id'].to_i)
        @contest.errors.add(:problems, val['problem_id'] + ' does not exist')
        return true
      end
      return false
    end
    if contest_params[:contest_problem_joints_attributes].nil?
      return true
    end
    ret = contest_params[:contest_problem_joints_attributes].to_unsafe_h.map { |key, val| l_check(val) }
    return !ret.any?
  end

  def is_started?
    Time.now >= @contest.start_time or current_user&.admin?
  end

  def check_started!
    unless is_started?
      flash[:notice] = 'Contest has not yet started.'
      redirect_to @contest
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contest_params
    params.require(:contest).permit(
      :id,
      :title,
      :description,
      :start_time,
      :end_time,
      :contest_type,
      :cd_time,
      :disable_discussion,
      :freeze_minutes,
      :show_detail_result,
      :hide_old_submission,
      :user_whitelist,
      compiler_ids: [],
      contest_problem_joints_attributes: [
        :id,
        :problem_id,
        :_destroy
      ]
    )
  end
end
