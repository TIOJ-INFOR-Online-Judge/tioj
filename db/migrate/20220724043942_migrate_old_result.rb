class MigrateOldResult < ActiveRecord::Migration[7.0]
  def up
    add_column :submission_tasks, :old_result, :string
    add_column :submission_tasks, :old_score, :decimal, precision: 18, scale: 6
    add_column :submission_tasks, :old_time, :decimal, precision: 12, scale: 3
    add_column :submission_tasks, :old_memory, :integer
    add_column :submissions, :old_result, :string
    add_column :submissions, :old_score, :decimal, precision: 18, scale: 6
    add_column :submissions, :old_time, :integer
    add_column :submissions, :old_memory, :integer
    add_column :submissions, :new_rejudged, :boolean, default: true
    add_index :submissions, [:contest_id, :new_rejudged, :result]
    add_index :submissions, [:contest_id, :new_rejudged, :id]
    add_index :submissions, [:contest_id, :user_id, :problem_id, :old_result], name: :index_submissions_old_user_query
    add_index :submissions, [:contest_id, :user_id, :result, :old_result], name: :index_submissions_old_user_result
    add_index :submissions, [:contest_id, :user_id, :result, :old_result, :problem_id], name: :index_submissions_old_user_problem_result
    SubmissionTask.update_all("old_result = result, old_score = score, old_time = time, old_memory = rss")
    Submission.update_all("old_result = result, old_score = score, old_time = total_time, old_memory = total_memory, new_rejudged = false")
    # after grace period: remove all these added column / indices
  end
end
