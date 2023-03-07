class MigrateOldResults < ActiveRecord::Migration[7.0]
  def change
    remove_index :submissions, [:contest_id, :new_rejudged, :result]
    remove_index :submissions, [:contest_id, :new_rejudged, :id]
    remove_index :submissions, [:contest_id, :user_id, :problem_id, :old_result], name: :index_submissions_old_user_query
    remove_index :submissions, [:contest_id, :user_id, :result, :old_result], name: :index_submissions_old_user_result
    remove_index :submissions, [:contest_id, :user_id, :result, :old_result, :problem_id], name: :index_submissions_old_user_problem_result

    reversible do |direction|
      direction.up do
        execute %{
          INSERT INTO old_submissions
            (submission_id, problem_id, result, score, time, memory, created_at, updated_at)
          SELECT id, problem_id, old_result, old_score, old_time, old_memory, NOW(), NOW()
          FROM submissions
          WHERE contest_id IS NULL AND old_result IS NOT NULL
        }
        execute %{
          INSERT INTO old_submission_tasks
            (old_submission_id, position, result, score, time, memory, created_at, updated_at)
          SELECT old_submissions.id, submission_tasks.position, submission_tasks.old_result,
                 submission_tasks.old_score, submission_tasks.old_time, submission_tasks.old_memory, NOW(), NOW()
          FROM submission_tasks
          INNER JOIN old_submissions ON submission_tasks.submission_id = old_submissions.submission_id
          WHERE submission_tasks.old_result IS NOT NULL
        }
      end
      direction.down do
        execute %{
          UPDATE submissions,
            (SELECT submission_id, result, score, time, memory FROM old_submissions) AS t
          SET submissions.old_result = t.result, submissions.old_score = t.score,
              submissions.old_time = t.time, submissions.old_memory = t.memory
          WHERE submissions.id = t.submission_id
        }
        execute %{
          UPDATE submission_tasks,
            (SELECT old_submissions.submission_id, old_submission_tasks.position,
                    old_submission_tasks.result, old_submission_tasks.score,
                    old_submission_tasks.time, old_submission_tasks.memory
             FROM old_submission_tasks
             INNER JOIN old_submissions ON old_submissions.id = old_submission_tasks.old_submission_id
            ) AS t
          SET submission_tasks.old_result = t.result, submission_tasks.old_score = t.score,
              submission_tasks.old_time = t.time, submission_tasks.old_memory = t.memory
          WHERE submission_tasks.submission_id = t.submission_id AND
                submission_tasks.position = t.position
        }
      end
    end

    add_index :old_submissions, [:problem_id, :result]
    remove_column :submission_tasks, :old_result, :string
    remove_column :submission_tasks, :old_score, :decimal, precision: 18, scale: 6
    remove_column :submission_tasks, :old_time, :integer
    remove_column :submission_tasks, :old_memory, :integer
    remove_column :submissions, :old_result, :string
    remove_column :submissions, :old_score, :decimal, precision: 18, scale: 6
    remove_column :submissions, :old_time, :integer
    remove_column :submissions, :old_memory, :integer
    remove_column :submissions, :new_rejudged, :boolean
    remove_column :problems, :old_pid, :integer
  end
end
