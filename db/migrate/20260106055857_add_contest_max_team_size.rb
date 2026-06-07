class AddContestMaxTeamSize < ActiveRecord::Migration[7.2]
  def change
    reversible do |direction|
      direction.up do
        change_column :contests, :allow_team_register, :integer, default: 0, null: false
        Contest.where(allow_team_register: 1).update_all(allow_team_register: -1)
      end
      direction.down do
        Contest.where(allow_team_register: -1).update_all(allow_team_register: 1)
        change_column :contests, :allow_team_register, :boolean, default: false, null: false
      end
    end
    rename_column :contests, :allow_team_register, :max_team_size
  end
end
