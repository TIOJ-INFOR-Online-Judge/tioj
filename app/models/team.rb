# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  teamname       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'file_size_validator'

class Team < ApplicationRecord
  has_and_belongs_to_many :users
  validates :users, length: { in: 1..10, message: "should be between 1 and 10." }
  accepts_nested_attributes_for :users

  has_and_belongs_to_many :team_contest_users, association_foreign_key: :user_id

  # validates_presence_of :teamname
  validates_length_of :teamname, in: 1..32

  validates :teamname,
    uniqueness: {case_sensitive: false},
    username_convention: true

#   validates_uniqueness_of :nickname
  validates_length_of :motto, maximum: 75
  validates :school, presence: true, length: {in: 1..64}

  mount_uploader :avatar, AvatarUploader
  validates :avatar,
    #presence: true,
    file_size: {
      maximum: 5.megabytes.to_i
    }

  def generate_random_avatar
    Tempfile.create(['', '.png']) do |tmpfile|
      Visicon.new(SecureRandom.random_bytes(16), '', 128).draw_image.write(tmpfile.path)
      self.avatar = tmpfile
    end
  end

  extend FriendlyId
  friendly_id :teamname
end

