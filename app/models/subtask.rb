# == Schema Information
#
# Table name: subtasks
#
#  id          :bigint           not null, primary key
#  problem_id  :bigint
#  score       :decimal(18, 6)
#  created_at  :datetime
#  updated_at  :datetime
#  td_list     :string(255)      not null
#  constraints :text(16777215)
#
# Indexes
#
#  index_subtasks_on_problem_id  (problem_id)
#

class Subtask < ApplicationRecord
  belongs_to :problem

  def td_list_arr(sz)
    NumberListStr.to_arr(td_list, sz)
  end

  def td_list_format
    td_list = NumberListStr.reduce(td_list, problem.testdata.count)
  end
end
