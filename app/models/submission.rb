# == Schema Information
#
# Table name: submissions
#
#  id              :bigint           not null, primary key
#  result          :string(255)      default("queued")
#  score           :decimal(18, 6)   default(0.0)
#  created_at      :datetime
#  updated_at      :datetime
#  problem_id      :bigint           default(0)
#  user_id         :bigint           default(0)
#  contest_id      :bigint
#  total_time      :integer
#  total_memory    :integer
#  message         :text(16777215)
#  compiler_id     :bigint           not null
#  code_length     :bigint           default(0), not null
#  code_content_id :bigint           not null
#
# Indexes
#
#  fk_rails_55e5b9f361                         (compiler_id)
#  index_submissions_contest_compiler          (contest_id,compiler_id,id DESC)
#  index_submissions_contest_result            (contest_id,result,id DESC)
#  index_submissions_fetch                     (result,contest_id,id)
#  index_submissions_on_code_content_id        (code_content_id)
#  index_submissions_on_contest_id             (contest_id)
#  index_submissions_on_result_and_updated_at  (result,updated_at)
#  index_submissions_on_user_id                (user_id)
#  index_submissions_problem_query             (contest_id,problem_id,user_id,result)
#  index_submissions_topcoder                  (contest_id,problem_id,result,score DESC,total_time,total_memory)
#  index_submissions_user_query                (contest_id,user_id,problem_id,result)
#
# Foreign Keys
#
#  fk_rails_...  (code_content_id => code_contents.id)
#  fk_rails_...  (compiler_id => compilers.id)
#

class Submission < ApplicationRecord
  belongs_to :problem
  belongs_to :user, class_name: 'UserBase'
  belongs_to :contest, optional: true
  belongs_to :compiler
  belongs_to :code_content

  has_one :old_submission, dependent: :destroy
  has_one :submission_subtask_result, dependent: :destroy
  has_many :submission_testdata_results, dependent: :delete_all

  validate :code_length_limit
  validates_length_of :message, in: 0..65000, allow_nil: true

  accepts_nested_attributes_for :code_content

  def code_length_limit
    if code_length > problem.code_length_limit
      errors.add(:code, "length limit exceeded (max #{problem.code_length_limit} bytes)")
    end
  end

  def contest?
    contest_id != nil
  end

  def allowed_for(cur_user, override_admin = nil)
    effective_admin = override_admin.nil? ? cur_user&.admin? : override_admin
    return true if effective_admin || !contest?
    return false if created_at >= contest.freeze_after && cur_user&.id != user_id
    return false unless contest.is_ended? or cur_user&.id == user_id
    true
  end

  def tasks_allowed_for(cur_user, override_admin = nil)
    effective_admin = override_admin.nil? ? cur_user&.admin? : override_admin
    !contest? || effective_admin || contest.show_detail_result
  end

  def calc_subtask_result(data = [], prefetched = false)
    num_tds, subtasks, n_problem, n_contest = data
    
    score_map = submission_testdata_results.map { |t| [t.position, t.score] }.to_h
    n_problem ||= problem
    n_contest ||= contest if contest_id
    skip_group = n_problem.skip_group || n_contest&.skip_group || false
    num_tds ||= prefetched ? n_problem.testdata.length : n_problem.testdata.count
    subtasks ||= prefetched ? n_problem.subtasks.sort_by(&:id) : n_problem.subtasks.order(id: :asc)
    subtasks.map.with_index{|s, index|
      lst = s.td_list_arr(num_tds)
      set_result = score_map.values_at(*lst)
      finished = skip_group ? set_result.any? : set_result.all?
      set_result = set_result.reject(&:nil?)
      ratio = finished ? (lst.size > 0 ? set_result.min.to_f / 100 : 1.0) : 0.0
      set_score = finished ? (((lst.size > 0 ? set_result.min : BigDecimal(100)) * s.score) / 100).round(n_problem.score_precision) : 0
      {score: set_score, ratio: ratio, position: index, finished: finished}
    }
  end

  def generate_subtask_result(prefetched = false)
    if submission_subtask_result
      submission_subtask_result.result = calc_subtask_result([], prefetched)
    else
      self.submission_subtask_result = SubmissionSubtaskResult.new(result: calc_subtask_result([], prefetched))
    end
  end

  def update_self_with_subtask_result(update_hash, subtask_scores = nil)
    subtask_scores ||= calc_subtask_result
    if submission_subtask_result
      submission_subtask_result.update(result: subtask_scores)
      update(**update_hash)
    else
      update(**update_hash, submission_subtask_result: SubmissionSubtaskResult.new(result: subtask_scores))
    end
  end

  def get_subtask_result
    submission_subtask_result.result
  end

  def created_at_usec
    created_at.to_i * 1000000 + created_at.usec
  end
end
