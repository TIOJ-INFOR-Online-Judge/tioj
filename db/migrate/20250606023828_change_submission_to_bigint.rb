class ChangeSubmissionToBigint < ActiveRecord::Migration[7.2]
  def change
    change_column :old_submission_testdata_results, :time, :bigint
    change_column :old_submission_testdata_results, :rss, :bigint
    change_column :old_submissions, :total_time, :bigint
    change_column :old_submissions, :total_memory, :bigint
    change_column :submission_testdata_results, :rss, :bigint
    change_column :submission_testdata_results, :vss, :bigint
    change_column :submissions, :total_time, :bigint
    change_column :submissions, :total_memory, :bigint
  end
end
