class ProblemsController < ApplicationController
  before_action :authenticate_admin!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_problem, only: [:show, :edit, :update, :destroy, :ranklist]
  before_action :set_contest, only: [:show]
  before_action :set_compiler, only: [:edit]
  before_action :reduce_list, only: [:create, :update]
  layout :set_contest_layout, only: [:show]

  def ranklist
    @submissions = (@problem.submissions.where(contest_id: nil, result: 'AC')
        .order(score: :desc, total_time: :asc, total_memory: :asc).order("LENGTH(code) ASC")
        .includes(:compiler))
    set_page_title "Ranklist - " + @problem.id.to_s + " - " + @problem.name
  end

  def index
    if not params[:search_id].blank?
      redirect_to problem_path(params[:search_id])
      return
    end

    # filtering
    @problems = Problem.includes(:tags)
    if not params[:search_name].blank?
      @problems = @problems.where("name LIKE ?", "%%%s%%"%params[:search_name])
    end
    if not params[:tag].blank?
      @problems = @problems.tagged_with(params[:tag])
    end

    @problems = @problems.order(id: :asc).page(params[:page]).per(100)

    problem_ids = @problems.map(&:id).to_a
    query_user_id = current_user ? current_user.id : 0
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

    set_page_title "Problems"
  end

  def show
    unless user_signed_in? && current_user.admin == true
      if @problem.visible_state == 1
        if params[:contest_id].blank?
          redirect_back fallback_location: root_path, :notice => 'Insufficient User Permissions.'
          return
        end
        unless @contest.problem_ids.include?(@problem.id) and Time.now >= @contest.start_time and Time.now <= @contest.end_time
          redirect_back fallback_location: root_path, :notice => 'Insufficient User Permissions.'
          return
        end
      elsif @problem.visible_state == 2
        redirect_to :back, :notice => 'Insufficient User Permissions.'
        return
      end
    end
    @tdlist = inverse_td_list(@problem)
    #@contest_id = params[:contest_id]
    set_page_title @problem.id.to_s + " - " + @problem.name
  end

  def new
    @problem = Problem.new
    set_page_title "New problem"
  end

  def edit
    @ban_compiler_ids = @problem.compilers.map(&:id).to_set
    set_page_title "Edit " + @problem.id.to_s + " - " + @problem.name
  end

  def create
    params[:problem][:compiler_ids] ||= []
    @problem = Problem.new(check_compiler())
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
    respond_to do |format|
      @problem.attributes = check_compiler()
      pre_ids = @problem.testdata_sets.collect(&:id)
      changed = @problem.testdata_sets.any? {|x| x.score_changed? || x.td_list_changed?}
      if @problem.save
        changed ||= pre_ids.sort != @problem.testdata_sets.collect(&:id).sort
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
    redirect_to action:'index'
    return
    # 'Deletion of problem may cause unwanted paginate behavior.'

    #@problem.destroy
    respond_to do |format|
      format.html { redirect_to problems_url, notice: 'Deletion of problem may cause unwanted paginate behavior.' }
      format.json { head :no_content }
    end
  end

  private
    def set_problem
      @problem = Problem.find(params[:id])
    end

    def set_contest
      @contest = Contest.find(params[:contest_id]) if not params[:contest_id].blank?
    end

    def set_compiler
      @compiler = @contest ? Compiler.where.not(id: @contest.compilers.map{|x| x.id}) : Compiler.all
      @compiler = @compiler.order(order: :asc).to_a
    end

    def reduce_list
      unless problem_params[:testdata_sets_attributes]
        return
      end
      problem_params[:testdata_sets_attributes].each do |x, y|
        params[:problem][:testdata_sets_attributes][x][:td_list] = \
            reduce_td_list(y[:td_list], @problem.testdata.count)
      end
    end

    def check_compiler
      params = problem_params.clone
      if params[:specjudge_type].to_i != 0 and not params[:specjudge_compiler_id]
        params[:specjudge_compiler_id] = Compiler.where(name: 'c++14').first.id
      end
      if params[:specjudge_type].to_i == 0 and params[:specjudge_compiler_id]
        params[:specjudge_compiler_id] = nil
      end
      return params
    end

    def recalc_score
      num_tasks = @problem.testdata.count
      tdset_map = @problem.testdata_sets.map{|s| [td_list_to_arr(s.td_list, num_tasks), s.score]}
      @problem.submissions.select(:id).each_slice(256) do |s|
        ids = s.map(&:id).to_a
        arr = SubmissionTask.where(:submission_id => ids).
            select(:submission_id, :position, :score).group_by(&:submission_id).map{ |x, y|
          td_map = y.map{|t| [t.position, t.score]}.to_h
          score = tdset_map.map{|td, td_score|
            (td.size > 0 ? td_map.values_at(*td).map{|x| x ? x : 0}.min : 100) * td_score
          }.sum / BigDecimal('100')
          max_score = BigDecimal('1e+12') - 1
          score = score.clamp(-max_score, max_score).round(6)
          {id: x, score: score.to_s}
        }
        Submission.import(arr, on_duplicate_key_update: [:score], validate: false, timestamps: false)
      end
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
        :specjudge_type,
        :specjudge_compiler_id,
        :interlib_type,
        :sjcode,
        :interlib,
        :old_pid,
        compiler_ids: [],
        testdata_sets_attributes:
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
