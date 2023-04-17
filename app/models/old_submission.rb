# == Schema Information
#
# Table name: old_submissions
#
#  id            :bigint           not null, primary key
#  submission_id :bigint
#  problem_id    :bigint
#  result        :string(255)
#  score         :decimal(18, 6)
#  total_time    :integer
#  total_memory  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_old_submissions_on_problem_id             (problem_id)
#  index_old_submissions_on_problem_id_and_result  (problem_id,result)
#  index_old_submissions_on_submission_id          (submission_id) UNIQUE
#  index_old_submissions_topcoder                  (problem_id,result,score DESC,total_time,total_memory)
#

class OldSubmission < ApplicationRecord
  belongs_to :problem
  belongs_to :submission
  has_many :old_submission_testdata_results, dependent: :delete_all

  def calc_subtask_scores
    score_map = old_submission_testdata_results.map { |t| [t.position, t.score] }.to_h
    num_tasks = problem.testdata.count
    skip_group = problem.skip_group
    problem.subtasks.order(id: :asc).map.with_index{|s, index|
      lst = s.td_list_arr(num_tasks)
      set_result = score_map.values_at(*lst)
      finished = skip_group ? set_result.any? : set_result.all?
      set_result = set_result.reject(&:nil?)
      ratio = finished ? (lst.size > 0 ? set_result.min.to_f / 100 : 1.0) : 0.0
      set_score = finished ? (((lst.size > 0 ? set_result.min : BigDecimal(100)) * s.score) / 100).round(problem.score_precision) : 0
      {score: set_score, ratio: ratio, position: index, finished: finished}
    }
  end
end
