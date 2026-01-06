class AddContestMaxTeamSize < ActiveRecord::Migration[7.2]
  def change
    change_column :contests, :allow_team_register, :integer, default: 0, null: false
    reversible do |direction|
      direction.up do
        Contest.where(allow_team_register: 1).update_all(allow_team_register: -1)
      end
      direction.down do
        Contest.where(allow_team_register: -1).update_all(allow_team_register: 1)
      end
    end
    rename_column :contests, :allow_team_register, :max_team_size
  end
end
