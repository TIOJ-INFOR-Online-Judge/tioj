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
    unless @contest.is_started?
      authenticate_admin!
    end

    self_only = false
    c_submissions = nil
    if @contest.type_ioi? and @contest.is_running?
      authenticate_user!
      if not current_user.admin?
        c_submissions = @contest.submissions.where("user_id = ?", current_user.id)
        flash[:notice] = "You can only see your own score."
        self_only = true
      else
        c_submissions = @contest.submissions
      end
    else
      c_submissions = @contest.submissions
    end

    freeze_start = (
        (current_user&.admin? && !params[:with_freeze]) || self_only ?
        @contest.end_time : @contest.freeze_after)
    if freeze_start != @contest.end_time and Time.now >= freeze_start
      flash.now[:notice] = "Scoreboard is now frozen."
    end

    if @contest.type_acm?
      @data = helpers.ranklist_data(c_submissions.order(:created_at), @contest.start_time, freeze_start, :acm)
    else
      @data = helpers.ranklist_data(c_submissions.order(:created_at), @contest.start_time, freeze_start, :ioi)
    end
    @participants = User.where(id: @data[:participants])
    @data[:tasks] = @tasks.map(&:id)
    @data[:contest_type] = @contest.contest_type
    @data[:timestamps] = {
      :start => helpers.to_us(@contest.start_time),
      :end => helpers.to_us(@contest.end_time),
      :freeze => helpers.to_us(@contest.freeze_after),
      :current => helpers.to_us(Time.now.clamp(@contest.start_time, @contest.end_time)),
    }
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
