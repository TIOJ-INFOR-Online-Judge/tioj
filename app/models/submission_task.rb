# == Schema Information
#
# Table name: submission_tasks
#
#  id            :integer          not null, primary key
#  submission_id :integer
#  position      :integer
#  result        :string(255)
#  time          :integer
#  memory        :integer
#  score         :decimal(18, 6)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class SubmissionTask < ActiveRecord::Base
  belongs_to :submission
end
