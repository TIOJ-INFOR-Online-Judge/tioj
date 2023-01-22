class AddFreezeTimeToContests < ActiveRecord::Migration[4.2]
  def change
    add_column :contests, :freeze_time, :integer, :null => false, :default_value => 0
  end
end
