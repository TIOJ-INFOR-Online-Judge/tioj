# == Schema Information
#
# Table name: team_user_joints
#
#  user_id :bigint           not null
#  team_id :bigint           not null
#  id      :bigint           not null, primary key
#
# Indexes
#
#  index_team_user_joints_on_team_id_and_user_id  (team_id,user_id) UNIQUE
#  index_team_user_joints_on_user_id_and_team_id  (user_id,team_id) UNIQUE
#
class TeamUserJoint < ApplicationRecord
  belongs_to :team
  belongs_to :user

  validates_associated :team
  validates_associated :user

  validates :user_id, uniqueness: {scope: :team_id, message: "has already been added to this team."}

  validate :team_limit_not_exceeded, on: :create
  validate :user_limit_not_exceeded, on: :create

  before_destroy :team_has_user, prepend: true do
    throw(:abort) if errors.present?
  end

  private

  def team_limit_not_exceeded
    max_teams_per_user = Rails.configuration.x.settings.dig(:max_teams_per_user) || 20
    if user.team_user_joints.count >= max_teams_per_user
      errors.add(:user, "can join at most #{max_teams_per_user} teams")
    end
  end

  def user_limit_not_exceeded
    max_members_per_team = Rails.configuration.x.settings.dig(:max_members_per_team) || 10
    if team.team_user_joints.count >= max_members_per_team
      errors.add(:team, "can contain at most #{max_members_per_team} users")
    end
  end

  def team_has_user
    logger.fatal "Attempting to remove user #{user.id} from team #{team.id} which has #{team.team_user_joints.count} users."
    if team.team_user_joints.count <= 1
      errors.add(:team, "must have at least one user. Delete the whole team instead.")
    end
  end
end
