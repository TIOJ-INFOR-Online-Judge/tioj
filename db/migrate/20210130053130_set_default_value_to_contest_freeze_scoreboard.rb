class SetDefaultValueToContestFreezeScoreboard < ActiveRecord::Migration
  def change
    change_column :contests, :freeze_time, :integer, :null => false, :default => 0
  end
end
