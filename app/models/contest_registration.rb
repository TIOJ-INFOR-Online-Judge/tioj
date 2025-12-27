# == Schema Information
#
# Table name: contest_registrations
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  contest_id :bigint           not null
#  approved   :boolean          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_id    :bigint
#
# Indexes
#
#  index_contest_registrations_on_contest_id_and_approved  (contest_id,approved)
#  index_contest_registrations_on_contest_id_and_team_id   (contest_id,team_id)
#  index_contest_registrations_on_contest_id_and_user_id   (contest_id,user_id) UNIQUE
#  index_contest_registrations_on_team_id                  (team_id)
#  index_contest_registrations_on_user_id_and_approved     (user_id,approved)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#

class ContestRegistration < ApplicationRecord
  default_scope { order('id ASC') }

  belongs_to :contest
  belongs_to :user, class_name: 'UserBase', foreign_key: :user_id
  belongs_to :team, optional: true

  validates_uniqueness_of :user, scope: :contest_id
end
