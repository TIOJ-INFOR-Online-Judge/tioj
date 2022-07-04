# == Schema Information
#
# Table name: submission_tasks
#
#  id            :bigint           not null, primary key
#  submission_id :bigint
#  position      :integer
#  result        :string(255)
#  time          :decimal(12, 3)
#  rss           :integer
#  score         :decimal(18, 6)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  vss           :integer
#

require 'test_helper'

class SubmissionTaskTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
