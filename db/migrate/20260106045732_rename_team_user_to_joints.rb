class RenameTeamUserToJoints < ActiveRecord::Migration[7.2]
  def change
    rename_table :teams_users, :team_user_joints
    add_column :team_user_joints, :id, :primary_key
  end
end
