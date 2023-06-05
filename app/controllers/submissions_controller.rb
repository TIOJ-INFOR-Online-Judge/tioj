class SubmissionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :authenticate_user_and_running_if_single_contest!, only: [:index, :show, :new, :create]
  before_action :authenticate_admin!, only: [:rejudge, :edit, :update, :destroy]
  before_action :set_submission, only: [:rejudge, :show, :show_old, :download_raw, :edit, :update, :destroy]
  before_action :set_problem_by_param, only: [:new, :create, :index]
  before_action :check_problem_visibility
  before_action :check_contest_status, only: [:new, :create]
  before_action :set_submissions, only: [:index]
  before_action :redirect_contest, only: [:show, :show_old, :download_raw, :edit]
  before_action :check_old, only: [:show_old]
  before_action :set_compiler, only: [:new, :create, :edit, :update]
  before_action :set_default_compiler, only: [:new, :edit]
  before_action :check_compiler, only: [:create, :update]
  before_action :normalize_code, only: [:create, :update]
  before_action :set_show_attrs, only: [:show, :show_old]
  layout :set_contest_layout, only: [:show, :index, :new, :edit]

  def rejudge
    @submission.submission_testdata_results.delete_all
    @submission.update_self_with_subtask_result({result: "queued", score: 0, total_time: nil, total_memory: nil, message: nil})
    ActionCable.server.broadcast('fetch', {type: 'notify', action: 'rejudge', submission_id: @submission.id})
    helpers.notify_contest_channel(@submission.contest_id, @submission.user_id)
    redirect_back fallback_location: root_path
  end

  def index
    @submissions = @submissions.order(id: :desc).page(params[:page]).preload(:user, :compiler, :problem)
    unless effective_admin?
      @submissions = @submissions.preload(:contest)
    end
  end

  def show
    unless effective_admin? or current_user&.id == @submission.user_id or not @submission.contest
      if not @submission.contest.is_ended?
        redirect_to contest_path(@submission.contest), notice: 'Submission is censored during contest.'
        return
      elsif @submission.created_at >= @contest.freeze_after
        redirect_to contest_path(@submission.contest), notice: 'Submission is censored before unfreeze.'
        return
      end
    end
    @_result = @submission.submission_testdata_results.index_by(&:position)
    @has_vss = @_result.empty? || @_result.values.any?{|x| x.vss}
    @show_old = false
  end

  def show_old
    @_result = @submission.old_submission.old_submission_testdata_results.index_by(&:position)
    @has_vss = false
    @show_old = true
    render :show
  end

  def download_raw
    if params[:inline] == '1'
      send_data @submission.code_content.code, filename: "#{@submission.id}#{@submission.compiler.extension}", disposition: 'inline', type: 'text/plain'
    else
      send_data @submission.code_content.code, filename: "#{@submission.id}#{@submission.compiler.extension}"
    end
  end

  def new
    if params[:problem_id].blank?
      redirect_to action:'index'
      return
    end
    @submission = Submission.new
    @submission.code_content = CodeContent.new
    @contest_id = params[:contest_id]
  end

  def create
    cd_time = @contest ? @contest.cd_time : 15
    user = current_user
    if user.admin?
      user.update(last_submit_time: Time.now)
    else
      user.with_lock do
        if not user.last_submit_time.blank? and Time.now - user.last_submit_time < cd_time
          redirect_to submissions_path, alert: 'CD time %d seconds.' % cd_time
          return
        end
        user.update(last_submit_time: Time.now)
      end
    end
    user.update(last_compiler_id: params[:submission][:compiler_id])

    raise_not_found unless @problem

    @submission = Submission.new(submission_params)
    @submission.user_id = current_user.id
    @submission.problem = @problem
    @submission.contest = @contest
    @submission.generate_subtask_result
    respond_to do |format|
      if @submission.save
        redirect_url = helpers.contest_adaptive_polymorphic_path([@submission], strip_prefix: false)
        ActionCable.server.broadcast('fetch', {type: 'notify', action: 'new', submission_id: @submission.id})
        helpers.notify_contest_channel(@submission.contest_id, @submission.user_id)
        format.html { redirect_to redirect_url, notice: 'Submission was successfully created.' }
        format.json { render action: 'show', status: :created, location: redirect_url }
      else
        format.html { render action: 'new' }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to @submission, notice: 'Submission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    helpers.notify_contest_channel(@submission.contest_id, @submission.user_id)
    @submission.destroy
    respond_to do |format|
      format.html { redirect_to submissions_url }
      format.json { head :no_content }
    end
  end

  private

  def set_problem_by_param
    @problem = Problem.find(params[:problem_id]) if params[:problem_id]
    raise_not_found if @problem && @contest && !@contest.problems.exists?(@problem.id)
  end

  def set_submissions
    @submissions = Submission
    @submissions = @submissions.where(problem_id: params[:problem_id]) if params[:problem_id]
    if @contest
      @submissions = @submissions.where(contest_id: @contest.id)
      unless effective_admin?
        if user_signed_in?
          @submissions = @submissions.where('submissions.created_at < ? OR submissions.user_id = ?', @contest.freeze_after, current_user.id)
        else
          @submissions = @submissions.where('submissions.created_at < ?', @contest.freeze_after)
        end
        # TODO: Add an option to still hide submission after contest
        unless @contest.is_ended?
          # only self submission
          if user_signed_in?
            @submissions = @submissions.where(user_id: current_user.id)
          else
            @submissions = Submission.none
            return
          end
        end
      end
    else
      @submissions = @submissions.where(contest_id: nil)
      unless effective_admin?
        @submissions = @submissions.joins(:problem).where(problem: {visible_state: :public})
      end
    end
    @submissions = @submissions.where(problem_id: params[:filter_problem]) if not params[:filter_problem].blank?
    if not params[:filter_username].blank?
      usr_clause = User.select(:id).where('username LIKE ?', params[:filter_username]).to_sql
      @submissions = @submissions.where("user_id IN (#{usr_clause})")
    end
    @submissions = @submissions.where(user_id: params[:filter_user_id]) if not params[:filter_user_id].blank?
    @submissions = @submissions.where(result: params[:filter_status]) if not params[:filter_status].blank?
    @submissions = @submissions.where(compiler_id: params[:filter_compiler].map{|x| x.to_i}) if not params[:filter_compiler].blank?
  end

  def set_submission
    @submission = Submission.find(params[:id])
    @problem = @submission.problem
    raise_not_found if @contest && @contest.id != @submission.contest_id
    @contest ||= @submission.contest
    if @contest
      unless effective_admin?
        # TODO: Add an option to still hide submission after contest
        raise_not_found if @submission.created_at >= @contest.freeze_after && current_user&.id != @submission.user_id
        raise_not_found unless @contest.is_ended? or current_user&.id == @submission.user_id
      end
    end
  end

  def redirect_contest
    if @layout == :application and @submission.contest_id
      redirect_to URI::join(contest_url(@contest) + '/', request.fullpath[1..]).to_s
    end
  end

  def check_old
    raise_not_found unless @submission.old_submission
  end

  def set_show_attrs
    @show_detail = @submission.tasks_allowed_for(current_user, effective_admin?)
    @tdlist = @submission.problem.subtasks
    @invtdlist = inverse_td_list(@submission.problem)
  end

  def set_compiler
    @problem = @submission.problem if not @problem
    @compiler = Compiler.where.not(id: @problem.compilers.map{|x| x.id})
    @compiler = @compiler.where.not(id: @contest.compilers.map{|x| x.id}) if @contest
    @compiler = @compiler.order(order: :asc).to_a
  end

  def set_default_compiler
    if @submission&.compiler_id
      @default_compiler_id = @submission.compiler_id
    else
      last_compiler = current_user&.last_compiler_id
      if @compiler.map(&:id).include?(last_compiler)
        @default_compiler_id = last_compiler
      else
        @default_compiler_id = @compiler[0].id
      end
    end
  end

  def check_compiler
    unless @compiler.any? { |c| c.id == submission_params[:compiler_id].to_i }
      redirect_to submissions_path, alert: 'Invalid compiler.'
      return
    end
  end

  def check_contest_status
    return unless @contest
    unless @contest.is_running?
      redirect_to contest_problem_path(@contest, @problem), alert: 'Contest is not running.'
      return
    end
    unless @contest.user_can_submit?(current_user)
      redirect_to contest_path(@contest), alert: 'You are not registered in this contest.'
      return
    end
    # TODO: delete user_whitelist to registration
    if Regexp.new(@contest.user_whitelist, Regexp::IGNORECASE).match(current_user.username).nil?
      redirect_to contest_problem_path(@contest, @problem), notice: 'You are not allowed to submit in this contest.'
      return
    end
  end

  def check_problem_visibility
    return if effective_admin? || !@problem
    raise_not_found if @problem.visible_invisible?
    raise_not_found if @problem.visible_contest? && !@contest
  end

  def normalize_code
    if params[:submission][:code_file]
      code = params[:submission][:code_file].read
    else
      code = params[:submission][:code_content_attributes][:code].encode('utf-8', universal_newline: true)
    end
    params[:submission][:code_content_attributes][:code] = code
    params[:submission][:code_length] = code.bytesize
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def submission_params
    params.require(:submission).permit(
      :compiler_id,
      :code_length,
      code_content_attributes: [:id, :code]
    )
  end
end
