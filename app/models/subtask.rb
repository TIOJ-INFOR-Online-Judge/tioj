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

  def self.td_list_str_to_arr(str, sz)
    str.split(',').map{|x|
      t = x.split('-')
      Range.new([0, t[0].to_i].max, [t[-1].to_i, sz - 1].min).to_a
    }.flatten.sort.uniq
  end

  def td_list_arr(sz)
    self.class.td_list_str_to_arr(td_list, sz)
  end
end
