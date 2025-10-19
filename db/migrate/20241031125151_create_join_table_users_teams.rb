class CreateJoinTableUsersTeams < ActiveRecord::Migration[7.0]
  def change
    create_join_table :users, :teams do |t|
      t.index [:user_id, :team_id], unique: true
      t.index [:team_id, :user_id], unique: true
    end
  end
end
