# == Schema Information
#
# Table name: contests
#
#  id                         :bigint           not null, primary key
#  title                      :string(255)
#  description                :text(16777215)
#  start_time                 :datetime
#  end_time                   :datetime
#  contest_type               :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  cd_time                    :integer          default(15), not null
#  disable_discussion         :boolean          default(TRUE), not null
#  freeze_minutes             :integer          default(0), not null
#  show_detail_result         :boolean          default(TRUE), not null
#  hide_old_submission        :boolean          default(FALSE), not null
#  user_whitelist             :text(65535)
#  skip_group                 :boolean          default(FALSE)
#  description_before_contest :text(16777215)
#  dashboard_during_contest   :boolean          default(TRUE)
#  register_mode              :integer          default("no_register"), not null
#  register_before            :datetime         not null
#
# Indexes
#
#  index_contests_on_start_time_and_end_time  (start_time,end_time)
#

class Contest < ApplicationRecord
  enum :contest_type, {ioi: 0, ioi_new: 1, acm: 2}, prefix: :type
  enum :register_mode, {no_register: 0, free_register: 1, require_approval: 2}

  has_many :contest_problem_joints, dependent: :destroy
  has_many :problems, through: :contest_problem_joints

  has_many :contest_users, dependent: :destroy

  # registration
  has_many :contest_registrations, dependent: :destroy
  has_many :registered_users,
      source: :user_base, through: :contest_registrations
  has_many :approved_registered_users, ->{ where(contest_registrations: {approved: true}) },
      source: :user_base, through: :contest_registrations

  # contest submissions will change to normal submissions once the contest is deleted
  has_many :submissions, dependent: :nullify
  has_many :posts, as: :postable, dependent: :destroy

  has_many :ban_compilers, as: :with_compiler, dependent: :destroy
  has_many :compilers, through: :ban_compilers, as: :with_compiler

  has_many :announcements, dependent: :destroy

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates_comparison_of :start_time, less_than: :end_time
  validates_numericality_of :freeze_minutes, greater_than_or_equal_to: 0

  accepts_nested_attributes_for :contest_problem_joints, reject_if: lambda { |a| a[:problem_id].blank? }, allow_destroy: true
  accepts_nested_attributes_for :ban_compilers, allow_destroy: true

  def freeze_after
    end_time - freeze_minutes * 60
  end

  def is_started?
    Time.now >= start_time
  end

  def is_ended?
    Time.now >= end_time
  end

  def is_running?
    Time.now >= start_time && end_time > Time.now
  end

  def can_register?
    Time.now < [register_before, end_time].min
  end

  def user_registered?(usr)
    usr && approved_registered_users.exists?(usr.id)
  end

  def user_can_submit?(usr)
    usr && (no_register? || approved_registered_users.exists?(usr.id))
  end
end
