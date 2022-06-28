class AddNewColumnsToContests < ActiveRecord::Migration[4.2]
  def change
    add_column :contests, :cd_time, :integer, :null => false, :default => 15
    add_column :contests, :disable_discussion, :boolean, :null => false, :default => true
  end
end
