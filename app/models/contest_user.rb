class ContestUser < UserBase
  belongs_to :contest
  validates :username,
    uniqueness: {case_sensitive: false, scope: :contest_id},
    username_convention: true
  validates_uniqueness_of :nickname, scope: :contest_id
end
