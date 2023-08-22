# == Schema Information
#
# Table name: old_submission_tasks
#
#  id                :bigint           not null, primary key
#  old_submission_id :bigint
#  position          :integer
#  result            :string(255)
#  score             :decimal(18, 6)
#  time              :integer
#  rss               :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_old_submission_tasks_on_old_submission_id  (old_submission_id)
#

class OldSubmissionTask < ApplicationRecord
  belongs_to :old_submission

  def message_type
    nil
  end
end
