class MigrateOldResults < ActiveRecord::Migration[7.0]
  def up
    Submission.where(contest_id: nil).where.not(old_result: nil).find_in_batches do |lst|
      data = lst.map {|s|
        {
          submission_id: s.id,
          problem_id: s.problem_id,
          result: s.old_result,
          score: s.old_score,
          time: s.old_time,
          memory: s.old_memory,
        }
      }
      OldSubmission.import(data)
    end
    mp = OldSubmission.pluck(:submission_id, :id).to_h
    mp.values.each_slice(256).each {|lst|
      data = SubmissionTask.where(submission_id: lst).where.not(old_result: nil).map { |s|
        {
          old_submission_id: mp[s.submission_id],
          position: s.position,
          result: s.old_result,
          score: s.old_score,
          time: s.old_time,
          memory: s.old_memory,
        }
      }
      OldSubmissionTask.import(data)
    }
    
    add_index :old_submissions, [:problem_id, :result]
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
