class RenameFreezeTime < ActiveRecord::Migration[7.0]
  def change
    rename_column :contests, :freeze_time, :freeze_minutes
  end
end
