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
#  code_content_id :bigint           not null
#  code_length     :bigint           default(0), not null
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
  belongs_to :user
  belongs_to :contest, optional: true
  belongs_to :compiler
  belongs_to :code_content
  has_many :submission_tasks, dependent: :delete_all

  has_one :old_submission, dependent: :destroy

  validate :code_length_limit
  validates_length_of :message, :in => 0..65000, :allow_nil => true

  accepts_nested_attributes_for :code_content

  def code_length_limit
    if code_length > problem.code_length_limit
      errors.add(:code, "length limit exceeded (max #{problem.code_length_limit} bytes)")
    end
  end

  def contest?
    contest_id != nil
  end

  def allowed_for(cur_user)
    return true if cur_user&.admin? || !contest?
    return false if created_at >= contest.freeze_after && cur_user&.id != user_id
    return false unless contest.is_ended? or cur_user&.id == user_id
    true
  end

  def tasks_allowed_for(cur_user)
    !contest? || cur_user&.admin? || contest.show_detail_result
  end

  def calc_td_set_scores
    score_map = submission_tasks.map { |t| [t.position, t.score] }.to_h
    num_tasks = problem.testdata.count
    skip_group = problem.skip_group || contest&.skip_group || false
    problem.testdata_sets.order(id: :asc).map.with_index{|s, index|
      lst = s.td_list_arr(num_tasks)
      set_result = score_map.values_at(*lst)
      finished = skip_group ? set_result.any? : set_result.all?
      set_result = set_result.reject(&:nil?)
      ratio = finished ? (lst.size > 0 ? set_result.min.to_f / 100 : 1.0) : 0.0
      set_score = finished ? (((lst.size > 0 ? set_result.min : BigDecimal(100)) * s.score) / 100).round(problem.score_precision) : 0
      {score: set_score, ratio: ratio, position: index, finished: finished}
    }
  end

  def created_at_usec
    created_at.to_i * 1000000 + created_at.usec
  end
end
