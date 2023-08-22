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
# Indexes
#
#  contest_task_ix  (contest_id,problem_id) UNIQUE
#

require 'test_helper'

class ContestProblemJointTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
