class DeleteOldResult < ActiveRecord::Migration[7.0]
  def change
    remove_index :submissions, [:contest_id, :new_rejudged, :result]
    remove_index :submissions, [:contest_id, :new_rejudged, :id]
    remove_index :submissions, [:contest_id, :user_id, :problem_id, :old_result], name: :index_submissions_old_user_query
    remove_index :submissions, [:contest_id, :user_id, :result, :old_result], name: :index_submissions_old_user_result
    remove_index :submissions, [:contest_id, :user_id, :result, :old_result, :problem_id], name: :index_submissions_old_user_problem_result
    remove_column :submission_tasks, :old_result
    remove_column :submission_tasks, :old_score
    remove_column :submission_tasks, :old_time
    remove_column :submission_tasks, :old_memory
    remove_column :submissions, :old_result
    remove_column :submissions, :old_score
    remove_column :submissions, :old_time
    remove_column :submissions, :old_memory
    remove_column :submissions, :new_rejudged
    remove_column :problems, :old_pid
  end
end
