# == Schema Information
#
# Table name: submissions
#
#  id           :bigint           not null, primary key
#  code         :text(4294967295)
#  result       :string(255)      default("queued")
#  score        :decimal(18, 6)   default(0.0)
#  created_at   :datetime
#  updated_at   :datetime
#  problem_id   :bigint           default(0)
#  user_id      :bigint           default(0)
#  contest_id   :bigint
#  total_time   :integer
#  total_memory :integer
#  message      :text(16777215)
#  compiler_id  :bigint           not null
#  old_result   :string(255)
#  old_score    :decimal(18, 6)
#  old_time     :integer
#  old_memory   :integer
#  new_rejudged :boolean          default(TRUE)
#

class Submission < ApplicationRecord
  belongs_to :problem
  belongs_to :user
  belongs_to :contest, optional: true
  belongs_to :compiler
  has_many :submission_tasks, dependent: :delete_all

  validates_length_of :code, :in => 0..5000000
  validates_length_of :message, :in => 0..65000, :allow_nil => true

  def contest?
    contest_id != nil
  end

  def allowed_for(cur_user)
    return true if cur_user&.admin? || !contest?
    return false if created_at >= contest.freeze_after && cur_user&.id != user_id
    if Time.now <= contest.end_time #and Time.now >= contest.start_time
      return false if cur_user&.id != user_id
    end
    true
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
end
