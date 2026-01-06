# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  avatar     :string(255)
#  motto      :string(255)
#  school     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  token      :string(255)
#
# Indexes
#
#  index_teams_on_name  (name) UNIQUE
#

require 'file_size_validator'

class Team < ApplicationRecord
  has_and_belongs_to_many :users
  accepts_nested_attributes_for :users, allow_destroy: true

  validates_length_of :name, in: 1..45

  validates :name, username_convention: true
  validates_uniqueness_of :name

  validates_length_of :motto, maximum: 75
  validates :school, presence: true, length: {in: 1..64}

  mount_uploader :avatar, AvatarUploader
  validates :avatar,
    file_size: {
      maximum: 5.megabytes.to_i
    }

  def generate_random_avatar
    if self.avatar.file.nil?
      Tempfile.create(['', '.png']) do |tmpfile|
        Visicon.new(SecureRandom.random_bytes(16), '', 128).draw_image.write(tmpfile.path)
        self.avatar = tmpfile
      end
    end
  end

  before_create :generate_token

  def generate_token
    self.token = SecureRandom.hex(20)
  end
end

