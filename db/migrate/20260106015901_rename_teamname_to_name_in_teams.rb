class RenameTeamnameToNameInTeams < ActiveRecord::Migration[7.2]
  def change
    rename_column :teams, :teamname, :name
    add_index :teams, [:name]
  end
end
