class RenameTables < ActiveRecord::Migration[7.0]
  def change
    rename_table :testdata_sets, :subtasks
    rename_table :old_submission_tasks, :old_submission_testdata_results
    rename_table :submission_tasks, :submission_testdata_results
  end
end
