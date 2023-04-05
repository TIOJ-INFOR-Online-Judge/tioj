# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string(255)      default(""), not null
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
#  username               :string(255)
#  motto                  :string(255)
#  school                 :string(255)
#  gradyear               :integer
#  name                   :string(255)
#  last_submit_time       :datetime
#  last_compiler_id       :bigint
#  user_type              :integer          default(5)
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_last_compiler_id      (last_compiler_id)
#  index_users_on_nickname              (nickname) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_user_type             (user_type)
#  index_users_on_username              (username) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (last_compiler_id => compilers.id)
#

require 'file_size_validator'
class User < ApplicationRecord
  enum :user_type, {admin: 10, normal_user: 5, contest_only: 0}

  has_many :submissions, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :articles, :dependent => :destroy

  belongs_to :last_compiler, class_name: 'Compiler', optional: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  devise :registerable unless Rails.configuration.x.settings.dig(:disable_registration)
  devise :recoverable if Rails.configuration.x.settings.dig(:mail_settings) || Rails.application.credentials.mail_settings

  mount_uploader :avatar, AvatarUploader
  validates :avatar,
    #:presence => true,
    :file_size => {
      :maximum => 5.megabytes.to_i
    }

  attr_accessor :login
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  validates_presence_of :username, :nickname
  validates :username,
    :uniqueness => {:case_sensitive => false},
    :username_convention => true,
    on: :create

  validates :school, :presence => true, :length => {:minimum => 1}
  validates :gradyear, :presence => true, :inclusion => 1..1000
  validates :name, :presence => true, :length => {:in => 1..12}

  validates_uniqueness_of :nickname
  validates_length_of :nickname, :in => 1..12
  validates_length_of :username, :in => 3..20
  validates_length_of :motto, :maximum => 75

  extend FriendlyId
  friendly_id :username
end
