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
class ContestUser < UserBase
  belongs_to :contest
  validates :username,
    uniqueness: {case_sensitive: false, scope: :contest_id},
    username_convention: true
  validates_uniqueness_of :nickname, scope: :contest_id
end
