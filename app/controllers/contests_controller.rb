class ContestsController < ApplicationController
  before_action :authenticate_user_and_running_if_single_contest!, only: [:dashboard, :dashboard_update]
  before_action :authenticate_user!, only: [:register]
  before_action :authenticate_admin!, only: [:set_contest_task, :new, :create, :edit, :update, :destroy]
  before_action :check_started!, only: [:dashboard]
  before_action :set_tasks, only: [:show, :dashboard, :dashboard_update, :set_contest_task]
  before_action :calculate_ranking, only: [:dashboard, :dashboard_update]
  layout :set_contest_layout, only: [:show, :edit, :dashboard, :sign_in]

  def set_contest_task
    redirect_to contest_path(@contest)
    alter_to = params[:alter_to].to_i
    name = Problem.visible_states.key(alter_to)
    flash[:notice] = "Contest tasks set to #{helpers.visible_state_desc_map[name]}."
    @tasks.map{|a| a.update(visible_state: alter_to)}
  end

  def calculate_ranking
    unless @contest.is_started?
      authenticate_admin!
    end

    self_only = false
    c_submissions = nil
    if not @contest.dashboard_during_contest and @contest.is_running?
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
    c_submissions = c_submissions.includes(:submission_subtask_result) if @contest.type_ioi_new?

    freeze_start = (
        (current_user&.admin? && !params[:with_freeze]) || self_only ?
        @contest.end_time : @contest.freeze_after)
    if freeze_start != @contest.end_time and Time.now >= freeze_start
      flash.now[:notice] = "Scoreboard is now frozen."
    end

    @data = helpers.ranklist_data(c_submissions.order(:created_at), @contest.start_time, freeze_start, @contest.contest_type)
    @data[:participants] |= @contest.approved_registered_users.ids
    @participants = UserBase.where(id: @data[:participants])
    @data[:tasks] = @tasks.map(&:id)
    @data[:contest_type] = @contest.contest_type
    @data[:user_id] = current_user&.id
    @data[:timestamps] = {
      start: helpers.to_us(@contest.start_time),
      end: helpers.to_us(@contest.end_time),
      freeze: helpers.to_us(@contest.freeze_after),
      current: helpers.to_us(Time.now.clamp(@contest.start_time, @contest.end_time)),
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
    @register_status = @contest.contest_registrations.where(user_id: current_user&.id).first&.approved
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
    update_registration = @contest.require_approval?
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
          if update_registration and !@contest.require_approval?
            @contest.contest_registrations.update_all(approved: true)
          end
          helpers.notify_contest_channel @contest.id
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

  def register
    unless @contest.can_register?
      flash[:alert] = 'Registration is closed.'
      redirect_to @contest
      return
    end
    if params[:cancel] == '1'
      @contest.contest_registrations.where(user_id: current_user.id).destroy_all
      respond_to do |format|
        format.html { redirect_to @contest, notice: 'Successfully unregistered.' }
        format.json { head :no_content }
      end
    else
      entry = @contest.contest_registrations.new(user_id: current_user.id, approved: !@contest.require_approval?)
      respond_to do |format|
        begin
          entry.save!
          format.html { redirect_to @contest, notice: @contest.require_approval? ? 'Registration request sent, approval pending.' : 'Successfully registered.' }
          format.json { head :no_content }
        rescue ActiveRecord::RecordNotUnique
          format.html { redirect_to @contest, alert: 'Registration failed.' }
          format.json { render json: @entry.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  ## Single Contest

  def sign_in_post
    sign_in_params = params.require(:user).permit(:username, :password)
    order_clause = UserBase.arel_table[:type].eq('ContestUser').desc # ORDER BY (type='ContestUser') DESC
    user = @contest.approved_registered_users.where(username: sign_in_params[:username]).order(order_clause).first
    if user && user.valid_password?(sign_in_params[:password])
      session[:single_contest] ||= {}
      session[:single_contest][@contest.id] ||= {}
      session[:single_contest][@contest.id][:user_id] = user.id
      url = session.dig(:single_contest, @contest.id, :previous_url)
      url = single_contest_path(@contest) unless url
      redirect_to url, notice: "Signed in successfully."
    else
      flash[:alert] = "Invalid login or password."
      render 'single_contest/sign_in', layout: 'single_contest'
    end
  end

  def sign_in
    render 'single_contest/sign_in'
  end

  def sign_out
    session[:single_contest].delete(@contest.id)
    redirect_to single_contest_path(@contest), notice: "Signed out successfully."
  end

 private

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
      :register_before,
      :register_mode,
      :contest_type,
      :cd_time,
      :disable_discussion,
      :freeze_minutes,
      :dashboard_during_contest,
      :show_detail_result,
      :hide_old_submission,
      :skip_group,
      :default_single_contest,
      compiler_ids: [],
      contest_problem_joints_attributes: [
        :id,
        :problem_id,
        :_destroy
      ]
    )
  end
end
