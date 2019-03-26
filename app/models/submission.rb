# == Schema Information
#
# Table name: submissions
#
#  id           :integer          not null, primary key
#  code         :text(16777215)
#  compiler     :integer          default(0)
#  result       :string(255)      default("queued")
#  score        :integer          default(0)
#  created_at   :datetime
#  updated_at   :datetime
#  problem_id   :integer          default(0)
#  user_id      :integer          default(0)
#  contest_id   :integer
#  _result      :text(65535)
#  total_time   :integer
#  total_memory :integer
#  message      :text(65535)
#

class Submission < ActiveRecord::Base
  belongs_to :problem
  belongs_to :user
  belongs_to :contest

  validates_length_of :code, :in => 0..5000000
  validates_length_of :message, :in => 0..65000, :allow_nil => true
  validates_inclusion_of :compiler, :in => 0..9
  validates_inclusion_of :compiler, :in => 0..6,
    :message => "only c/c++ are allowed during contest",
    :if => :contest?

  def contest?
    contest_id != nil
  end

end
