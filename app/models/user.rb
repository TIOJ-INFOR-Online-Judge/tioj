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

  has_and_belongs_to_many :teams
end

