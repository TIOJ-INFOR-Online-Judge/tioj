class RenameTeamnameToNameInTeams < ActiveRecord::Migration[7.2]
  def change
    rename_column :teams, :teamname, :name
  end
end
