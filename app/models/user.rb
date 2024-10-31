# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string(255)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  nickname               :string(255)
#  avatar                 :string(255)
#  admin                  :boolean          default(FALSE)
#  username               :string(255)
#  motto                  :string(255)
#  school                 :string(255)
#  gradyear               :integer
#  name                   :string(255)
#  last_submit_time       :datetime
#  last_compiler_id       :bigint
#  type                   :string(255)      default("User"), not null
#  contest_id             :bigint
#
# Indexes
#
#  index_users_on_contest_id                        (contest_id)
#  index_users_on_last_compiler_id                  (last_compiler_id)
#  index_users_on_type_and_contest_id_and_email     (type,contest_id,email) UNIQUE
#  index_users_on_type_and_contest_id_and_nickname  (type,contest_id,nickname) UNIQUE
#  index_users_on_type_and_email                    (type,email) UNIQUE
#  index_users_on_type_and_reset_password_token     (type,reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (contest_id => contests.id)
#  fk_rails_...  (last_compiler_id => compilers.id)
#

require 'file_size_validator'

class UserBase < ApplicationRecord
  self.table_name = "users"

  has_many :submissions, dependent: :destroy, foreign_key: :user_id
  has_many :posts, dependent: :destroy, foreign_key: :user_id
  has_many :comments, dependent: :destroy, foreign_key: :user_id

  has_many :contest_registrations, dependent: :destroy, foreign_key: :user_id
  has_many :registered_contests, source: :contest, through: :contest_registrations

  belongs_to :last_compiler, class_name: 'Compiler', optional: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable
  devise :registerable unless Rails.configuration.x.settings.dig(:disable_registration)
  devise :recoverable if Rails.configuration.x.settings.dig(:mail_settings)

  validates_presence_of :username, :nickname
  validates_length_of :nickname, in: 1..12
  validates_length_of :username, in: 3..20

  mount_uploader :avatar, AvatarUploader
  validates :avatar,
    #presence: true,
    file_size: {
      maximum: 5.megabytes.to_i
    }

  attr_accessor :login
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def generate_random_avatar
    Tempfile.create(['', '.png']) do |tmpfile|
      Visicon.new(SecureRandom.random_bytes(16), '', 128).draw_image.write(tmpfile.path)
      self.avatar = tmpfile
    end
  end
end

class User < UserBase
  devise :validatable

  has_many :articles, dependent: :destroy

  validates :username,
    uniqueness: {case_sensitive: false},
    username_convention: true,
    on: :create

  validates :school, presence: true, length: {in: 1..64}
  validates :gradyear, presence: true, inclusion: 1..3000
  validates :name, presence: true, length: {in: 1..12}

  validates_uniqueness_of :nickname
  validates_length_of :motto, maximum: 75

  extend FriendlyId
  friendly_id :username

  def self.ransackable_attributes(auth_object = nil)
    [
      "created_at", "updated_at", "id", "id_value", "username", "email", "admin",
      "motto", "name", "nickname", "avatar", "gradyear", "school",
      "current_sign_in_at", "last_sign_in_at",
      "current_sign_in_ip", "last_sign_in_ip", "sign_in_count",
      "last_compiler_id", "last_submit_time",
      "remember_created_at", "reset_password_sent_at"
    ]
  end

  has_and_belongs_to_many :teams,
                          join_table: 'teams_users',
                          foreign_key: :user_id,
                          association_foreign_key: :team_id
end

class ContestUser < UserBase
  belongs_to :contest
  validates :username,
    uniqueness: {case_sensitive: false, scope: :contest_id},
    username_convention: true
  validates_uniqueness_of :nickname, scope: :contest_id
end

class TeamContestUser < UserBase
  belongs_to :team
  belongs_to :contest
  validates :username,
    uniqueness: {case_sensitive: false, scope: :contest_id},
    username_convention: true
  validates_uniqueness_of :nickname, scope: :contest_id
end

# class Team < UserBase
#   has_and_belongs_to_many :users,
#                           join_table: 'teams_users',
#                           foreign_key: :team_id,
#                           association_foreign_key: :user_id
#   validates :users, length: { in: 1..10, message: "should be between 1 and 10." }
#   accepts_nested_attributes_for :users

#   alias_attribute :teamname, :username
#   validates :teamname,
#     uniqueness: {case_sensitive: true},
#     username_convention: true

#   validates_uniqueness_of :nickname
#   validates_length_of :motto, maximum: 75

#   validates :school, presence: true, length: {in: 1..64}
#   # validates :gradyear, presence: true, inclusion: 1..3000
#   # validates :name, presence: true, length: {in: 1..12}

#   def password_required?
#     false
#   end

#   extend FriendlyId
#   friendly_id :teamname
# end
