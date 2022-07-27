class SetDefaultValueToContestFreezeScoreboard < ActiveRecord::Migration[7.0]
  def change
    change_column :contests, :freeze_time, :integer, :null => false, :default => 0
  end
end
