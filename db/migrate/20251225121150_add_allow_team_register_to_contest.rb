class AddAllowTeamRegisterToContest < ActiveRecord::Migration[7.2]
  def change
    add_column :contests, :allow_team_register, :boolean, default: false, null: false
  end
end
