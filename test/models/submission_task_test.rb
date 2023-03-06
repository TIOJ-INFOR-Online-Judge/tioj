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
#  message_type  :string(255)
#  message       :text(16777215)
#
# Indexes
#
#  index_submission_tasks_on_submission_id               (submission_id)
#  index_submission_tasks_on_submission_id_and_position  (submission_id,position) UNIQUE
#

require 'test_helper'

class SubmissionTaskTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
