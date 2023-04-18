class ProblemsController < ApplicationController
  before_action :authenticate_admin!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_problem, only: [:show, :edit, :update, :destroy, :ranklist, :ranklist_old, :rejudge]
  before_action :set_testdata, only: [:show]
  before_action :set_compiler, only: [:new, :edit]
  before_action :reduce_list, only: [:create, :update]
  before_action :check_visibility!, only: [:show, :ranklist, :ranklist_old]
  layout :set_contest_layout, only: [:show]

  def ranklist
    # avoid additional COUNT(*) query by to_a
    @submissions = (@problem.submissions.where(contest_id: nil, result: 'AC')
        .order(score: :desc, total_time: :asc, total_memory: :asc, code_length: :asc, id: :asc)
        .includes(:compiler).preload(:user)).to_a
    @ranklist_old = false
  end

  def ranklist_old
    @submissions = (@problem.submissions.joins(:old_submission).where(old_submission: {result: 'AC'})
        .order("old_submission.score DESC, old_submission.total_time ASC, old_submission.total_memory ASC").order(code_length: :asc, id: :asc)
        .includes(:old_submission, :compiler).preload(:user)).to_a
    @ranklist_old = true
    render :ranklist
  end

  def delete_submissions
    Submission.where(problem_id: params[:id]).destroy_all
    ContestProblemJoint.where(problem_id: params[:id]).each do |x|
      helpers.notify_contest_channel x.contest_id
    end
    redirect_back fallback_location: root_path
  end

  def rejudge
    subs = Submission.where(problem_id: params[:id])
    sub_ids = subs.pluck(:id)
    SubmissionTestdataResult.where(submission_id: sub_ids).delete_all
    subtask_results = SubmissionSubtaskResult.where(submission_id: sub_ids)
    subs.update_all(:result => "queued", :score => 0, :total_time => nil, :total_memory => nil, :message => nil)
    subtask_results.update_all(result: subs.first.calc_subtask_result) if subs.first
    ActionCable.server.broadcast('fetch', {type: 'notify', action: 'problem_rejudge', problem_id: params[:problem_id].to_i})
    ContestProblemJoint.where(problem_id: params[:id]).each do |x|
      helpers.notify_contest_channel x.contest_id
    end
    redirect_back fallback_location: root_path
  end

  def index
    if not params[:search_id].blank?
      redirect_to problem_path(params[:search_id])
      return
    end

    # filtering
    @problems = Problem.includes(:tags, :solution_tags)
    if not params[:search_name].blank?
      sanitized = ActiveRecord::Base.send(:sanitize_sql_like, params[:search_name])
      @problems = @problems.where("name LIKE ?", "%#{sanitized}%")
    end
    if not params[:tag].blank?
      @problems = @problems.tagged_with(params[:tag])
    end

    @problems = @problems.order(id: :asc).page(params[:page]).per(100)

    problem_ids = @problems.map(&:id).to_a
    query_user_id = current_user&.id || 0
    attributes = [
      :id,
      "COUNT(DISTINCT CASE WHEN s.result = 'AC' THEN s.user_id END) user_ac",
      "COUNT(DISTINCT s.user_id) user_cnt",
      "COUNT(CASE WHEN s.result = 'AC' THEN 1 END) sub_ac",
      "COUNT(s.id) sub_cnt",
      "BIT_OR(s.result = 'AC' AND s.user_id = %d) cur_user_ac" % query_user_id,
      "BIT_OR(s.user_id = %d) cur_user_tried" % query_user_id,
    ]
    @attr_map = (Problem.select(*attributes)
        .where(:id => problem_ids)
        .joins("LEFT JOIN submissions s ON s.problem_id = problems.id AND s.contest_id IS NULL")
        .group(:id)
        .index_by(&:id))
  end

  def show
    @tdlist = inverse_td_list(@problem)
  end

  def new
    @problem = Problem.new
    1.times { @problem.sample_testdata.build }
    @ban_compiler_ids = Set[]
  end

  def edit
    if @problem.sample_testdata.length == 0
      1.times { @problem.sample_testdata.build }
    end
    @ban_compiler_ids = @problem.compilers.map(&:id).to_set
  end

  def create
    params[:problem][:compiler_ids] ||= []
    @problem = Problem.new(check_params())
    @ban_compiler_ids = params[:problem][:compiler_ids].map(&:to_i).to_set
    respond_to do |format|
      if @problem.save
        format.html { redirect_to @problem, notice: 'Problem was successfully created.' }
        format.json { render action: 'show', status: :created, location: @problem }
      else
        format.html { render action: 'new' }
        format.json { render json: @problem.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params[:problem][:compiler_ids] ||= []
    @ban_compiler_ids = params[:problem][:compiler_ids].map(&:to_i).to_set
    respond_to do |format|
      @problem.attributes = check_params()
      pre_ids = @problem.subtasks.collect(&:id)
      changed = @problem.subtasks.any? {|x| x.score_changed? || x.td_list_changed?}
      changed ||= @problem.score_precision_changed?
      if @problem.save
        changed ||= pre_ids.sort != @problem.subtasks.collect(&:id).sort
        if changed
          recalc_score
        end
        format.html { redirect_to @problem, notice: 'Problem was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @problem.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      format.html { redirect_to problems_url, alert: "Deletion of problem is disabled since it will cause unwanted paginate behavior." }
      format.json { head :no_content }
    end
  end

  private

  def set_problem
    @problem = Problem.find(params[:id])
  end

  def set_testdata
    @testdata = @problem.testdata
    @has_rss = @testdata.any?{|x| x.rss_limit}
    @has_vss = @testdata.any?{|x| x.vss_limit}
  end

  def set_compiler
    @compiler = @contest ? Compiler.where.not(id: @contest.compilers.map{|x| x.id}) : Compiler.all
    @compiler = @compiler.order(order: :asc).to_a
  end

  def reduce_list
    if problem_params[:subtasks_attributes]
      problem_params[:subtasks_attributes].each do |x, y|
        params[:problem][:subtasks_attributes][x][:td_list] = \
            reduce_td_list(y[:td_list], @problem ? @problem.testdata.count : 0)
      end
    end
    if problem_params[:verdict_ignore_td_list]
      params[:problem][:verdict_ignore_td_list] = \
          reduce_td_list(problem_params[:verdict_ignore_td_list], @problem ? @problem.testdata.count : 0)
    end
  end

  def recalc_score
    num_tds = @problem.testdata.count
    subtasks = @problem.subtasks
    contests_map = @problem.contests.all.index_by(&:id)
    @problem.submissions.includes(:submission_testdata_results).find_in_batches(batch_size: 1024) do |batch|
      data = batch.map do |sub|
        {
          submission_id: sub.id,
          result: sub.calc_subtask_result([num_tds, subtasks, @problem, contests_map[sub.contest_id]]),
        }
      end
      sub_data = data.map do |item|
        {
          id: item[:submission_id],
          score: item[:result].map{|x| x[:score]}.sum.to_s,
          compiler_id: 0,
          code_content_id: 0,
        }
      end
      Submission.import(sub_data, on_duplicate_key_update: [:score], validate: false, timestamps: false)
      SubmissionSubtaskResult.import(data, on_duplicate_key_update: [:result], validate: false)
    end
  end

  def check_visibility!
    unless effective_admin?
      if @problem.visible_contest?
        if params[:contest_id].blank? or not (@contest.problem_ids.include?(@problem.id) and @contest.is_started?)
          redirect_back fallback_location: root_path, :alert => 'Insufficient User Permissions.'
        end
      elsif @problem.visible_invisible?
        redirect_back fallback_location: root_path, :alert => 'Insufficient User Permissions.'
      end
    end
  end

  def check_params
    params = problem_params.clone
    if params[:specjudge_type] != 'none' and not params[:specjudge_compiler_id] and not @problem&.specjudge_compiler_id
      params[:specjudge_compiler_id] = Compiler.order(order: :asc).first.id
    end
    if params[:specjudge_type] == 'none'
      params[:judge_between_stages] = false
    end
    params
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def problem_params
    params.require(:problem).permit(
      :id,
      :name,
      :description,
      :input,
      :output,
      :example_input,
      :example_output,
      :hint,
      :source,
      :limit,
      :page,
      :visible_state,
      :tag_list,
      :solution_tag_list,
      :discussion_visibility,
      :score_precision,
      :verdict_ignore_td_list,
      :num_stages,
      :specjudge_type,
      :specjudge_compiler_id,
      :judge_between_stages,
      :default_scoring_args,
      :interlib_type,
      :sjcode,
      :interlib,
      :interlib_impl,
      :code_length_limit,
      :ranklist_display_score,
      :strict_mode,
      :skip_group,
      sample_testdata_attributes:
      [
        :id,
        :problem_id,
        :input,
        :output,
        :_destroy
      ],
      compiler_ids: [],
      subtasks_attributes:
      [
        :id,
        :td_list,
        :constraints,
        :score,
        :_destroy
      ]
    )
  end
end
