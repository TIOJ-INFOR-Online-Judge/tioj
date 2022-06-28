class AddOldPidToProblem < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :old_pid, :integer
  end
end
