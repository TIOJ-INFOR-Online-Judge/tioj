# == Schema Information
#
# Table name: submission_testdata_results
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
#  index_submission_testdata_results_on_submission_id               (submission_id)
#  index_submission_testdata_results_on_submission_id_and_position  (submission_id,position) UNIQUE
#

class SubmissionTestdataResult < ApplicationRecord
  belongs_to :submission

  validates_length_of :message, maximum: 32768
end
