class AddFreezeTimeToContests < ActiveRecord::Migration
  def change
    add_column :contests, :freeze_time, :integer, :null => false, :default_value => 0
  end
end
