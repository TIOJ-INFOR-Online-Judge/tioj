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
#  compiler_id  :bigint           not null
#  old_result   :string(255)
#  old_score    :decimal(18, 6)
#  old_time     :integer
#  old_memory   :integer
#  new_rejudged :boolean          default(TRUE)
#

class Submission < ApplicationRecord
  belongs_to :problem
  belongs_to :user
  belongs_to :contest, optional: true
  belongs_to :compiler
  has_many :submission_tasks, dependent: :delete_all

  validates_length_of :code, :in => 0..5000000
  validates_length_of :message, :in => 0..65000, :allow_nil => true

  def contest?
    contest_id != nil
  end

  def allowed_for(cur_user)
    return true if cur_user&.admin? || !contest?
    return false if created_at >= contest.freeze_after && cur_user&.id != user_id
    if Time.now <= contest.end_time #and Time.now >= contest.start_time
      return false if cur_user&.id != user_id
    end
    true
  end
end
