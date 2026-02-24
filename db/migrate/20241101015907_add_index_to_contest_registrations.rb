class AddIndexToContestRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_index :contest_registrations, [:contest_id, :team_id]
  end
end
