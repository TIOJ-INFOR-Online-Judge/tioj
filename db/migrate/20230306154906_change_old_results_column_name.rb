class ChangeOldResultsColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :old_submissions, :memory, :total_memory
    rename_column :old_submissions, :time, :total_time
    rename_column :old_submission_tasks, :memory, :rss
  end
end
