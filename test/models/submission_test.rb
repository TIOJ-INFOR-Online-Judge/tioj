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
#  compiler_id  :bigint           default(1), not null
#  old_result   :string(255)
#  old_score    :decimal(18, 6)
#  old_time     :integer
#  old_memory   :integer
#  new_rejudged :boolean          default(TRUE)
#

require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
