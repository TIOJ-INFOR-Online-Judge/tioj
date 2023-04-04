class ContestsController < ApplicationController
  before_action :authenticate_admin!, except: [:dashboard, :dashboard_update, :index, :show]
  before_action :set_contest, only: [:show, :edit, :update, :destroy, :dashboard, :dashboard_update, :set_contest_task]
  before_action :check_started!, only: [:dashboard]
  before_action :set_tasks, only: [:show, :dashboard, :dashboard_update, :set_contest_task]
  before_action :calculate_ranking, only: [:dashboard, :dashboard_update]
  layout :set_contest_layout, only: [:show, :dashboard, :dashboard_update]

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
        next id if prv && func[n] == func[prv]
        prv = n.clone
        id += run
        run = 0
        id
      end
    end
    @contest_submissions = c_submissions.select([:id, :problem_id, :user_id, :result, :score, :created_at]).to_a
    @submissions = @contest_submissions.group_by(&:problem_id)
    @participants = User.find(@contest_submissions.map(&:user_id).uniq)
    # array of submissions grouped by problems
    @submissions = @tasks.map{|x| @submissions[x.id] or []}
    @scores = []
    freeze_start = current_user&.admin? ? @contest.end_time : @contest.freeze_after
    waiting_verdicts = ['queued', 'received', 'Validating']
    if @contest.type_acm?
      uncounted = ['CE', 'ER', 'CLE', 'JE'] + waiting_verdicts
      first_solved = @submissions.map{|sub| sub.select{|a| a.result == 'AC'}.min_by(&:id)}.map{|a| a ? a.id : -1}
      @participants.each do |u|
        results = []
        total_attempts = 0
        total_solv = 0
        last_ac = 0
        penalty = 0
        @submissions.zip(first_solved).each do |sub, firstsolve|
          user_sub = sub.select{|s| s.user_id == u.id}
          first_ac = user_sub.select{|s| s.result == 'AC' and s.created_at < freeze_start}.min_by{|s| s.id}
          if first_ac
            attempts = user_sub.select{|s| s.id < first_ac.id and not s.result.in?(uncounted) and s.created_at < freeze_start}.size
            ac_time = (first_ac.created_at - @contest.start_time).to_i / 60
            last_ac = [last_ac, ac_time].max
            results << [attempts + 1, ac_time, first_ac.id == firstsolve, 0]
            total_solv += 1
            total_attempts += attempts + 1
            penalty += attempts * 20
          else
            attempts = user_sub.select{|s| not s.result.in?(uncounted) and s.created_at < freeze_start}.size
            pend = user_sub.select{|s| s.result.in?(waiting_verdicts) or s.created_at >= freeze_start}.size
            results << [attempts, -1, false, pend]
            total_attempts += attempts
          end
        end
        penalty += results.sum{|a| a[1] == -1 ? 0 : a[1]}
        @scores << [u, total_attempts, total_solv, results, penalty, last_ac]
      end
      @scores.sort_by!{|a| [-a[2], a[4], a[5]]}
      @scores = @scores.zip(Rank(@scores){|a| [a[2], a[4], a[5]]}).map {|n| n[0] + [n[1]]}
      @color = @scores.map{|a| a[2]}.uniq.sort_by{|a| -a}
      @color << 0
    else
      @participants.each do |u|
        results = []
        @submissions.each do |sub|
          user_sub = sub.select{|s| s.user_id == u.id}
          if user_sub.empty?
            results << [0, 0]
          else
            has_ac = user_sub.any?{|s| s.result == 'AC' and s.created_at < freeze_start}
            pending_count = user_sub.count{|s| s.result.in?(waiting_verdicts) or s.created_at >= freeze_start}
            pending = has_ac ? 0 : pending_count
            max_score = user_sub.select{|s| s.created_at < freeze_start}.max_by{|a| a.score}&.score || 0
            results << [max_score, pending]
          end
        end
        @scores << [u, results, results.sum{|a| a[0]}]
      end
      @scores.sort_by!{|a| -a[2]}
      @scores = @scores.zip(Rank(@scores){|a| a[2]}).map {|n| n[0] + [n[1]]}
      @color = @scores.map{|a| a[2]}.uniq.sort_by{|a| -a}
      @color << 0
    end
    if not current_user&.admin? and Time.now >= freeze_start and @contest.freeze_minutes != 0
      flash.now[:notice] = "Scoreboard is now frozen."
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
    @ban_compiler_ids = params[:contest][:compiler_ids].map{|x| x.to_i}.to_set
    respond_to do |format|
      if !tasks_valid?
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
    @ban_compiler_ids = params[:contest][:compiler_ids].map{|x| x.to_i}.to_set
    respond_to do |format|
      if !tasks_valid?
        format.html { render action: 'edit' }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      else
        begin
          ret = @contest.update(contest_params)
        rescue ActiveRecord::RecordNotUnique
          params[:contest][:contest_problem_joints_attributes].each {|key, val| val.delete(:id)}
          ActiveRecord::Base.transaction do
            @contest.contest_problem_joints.destroy_all()
            ret = @contest.update(contest_params)
          end
        end
        if ret
          format.html { redirect_to @contest, notice: 'Contest was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @contest.errors, status: :unprocessable_entity }
        end
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

  def tasks_valid?
    problem_params = contest_params[:contest_problem_joints_attributes]&.values
    return true if problem_params.nil?
    problems = problem_params.map { |val| Integer(val['problem_id'], exception: false) }
    if problems.any?{ |e| e.nil? }
      @contest.errors.add(:problems, '- Invalid problem')
      return false
    end
    if problems.size != problems.to_set.size
      @contest.errors.add(:problems, '- Duplicate problems')
      return false
    end
    valid_problems = Problem.where(id: problems).pluck(:id)
    if problems.size != valid_problems.size
      invalid_problems = problems - valid_problems
      @contest.errors.add(:problems, 'not exist: ' + invalid_problems.join(', '))
      return false
    end
    return true
  end

  def check_started!
    unless @contest.is_started? || current_user&.admin?
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
      :description_before_contest,
      :start_time,
      :end_time,
      :contest_type,
      :cd_time,
      :disable_discussion,
      :freeze_minutes,
      :show_detail_result,
      :hide_old_submission,
      :skip_group,
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
