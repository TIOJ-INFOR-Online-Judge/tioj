# == Schema Information
#
# Table name: submissions
#
#  id           :integer          not null, primary key
#  code         :text(16777215)
#  result       :string(255)      default("queued")
#  score        :decimal(18, 6)   default(0.0)
#  created_at   :datetime
#  updated_at   :datetime
#  problem_id   :integer          default(0)
#  user_id      :integer          default(0)
#  contest_id   :integer
#  total_time   :integer
#  total_memory :integer
#  message      :text(65535)
#  compiler_id  :integer          not null
#

require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
