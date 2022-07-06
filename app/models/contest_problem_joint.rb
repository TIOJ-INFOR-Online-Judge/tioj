# == Schema Information
#
# Table name: contest_problem_joints
#
#  id         :bigint           not null, primary key
#  contest_id :bigint
#  problem_id :bigint
#  created_at :datetime
#  updated_at :datetime
#

class ContestProblemJoint < ApplicationRecord
  default_scope { order('id ASC') }

  belongs_to :contest
  belongs_to :problem
end
