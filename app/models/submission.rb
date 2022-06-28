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
#

class Submission < ActiveRecord::Base
  belongs_to :problem
  belongs_to :user
  belongs_to :contest
  belongs_to :compiler
  has_many :submission_tasks, dependent: :delete_all

  validates_length_of :code, :in => 0..5000000
  validates_length_of :message, :in => 0..65000, :allow_nil => true

  def contest?
    contest_id != nil
  end

end
