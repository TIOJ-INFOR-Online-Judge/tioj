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
  validate :validate_max_team_size, on: :create

  def validate_max_team_size
    logger.fatal "Validating team size for contest #{contest.id} and team #{team&.id}"
    logger.fatal "Contest max team size: #{contest.max_team_size}"
    return if team.nil? || contest.max_team_size == -1
    if contest.max_team_size == 0
      errors.add(:team, "registration is not allowed for this contest")
    else
      registration_list = contest.contest_registrations.where(team_id: team.id).map{|reg| reg.id }.to_set
      registration_list.add(self.id)
      logger.fatal "Current team registration list: #{registration_list.to_a}"
      if registration_list.size > contest.max_team_size
        errors.add(:team, "exceeds the maximum team size of #{contest.max_team_size}")
      end
    end
  end
end
