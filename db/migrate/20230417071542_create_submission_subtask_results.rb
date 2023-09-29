class CreateSubmissionSubtaskResults < ActiveRecord::Migration[7.0]
  def change
    create_table :submission_subtask_results do |t|
      t.references :submission, index: { unique: true }, foreign_key: true, null: false
      t.binary :result, :limit => 16.megabyte - 1

      t.timestamps
    end
    reversible do |direction|
      direction.up do
        num_tds_map = Testdatum.group(:problem_id).count
        subtasks_map = Subtask.all.group_by(&:problem_id)
        problems_map = Problem.all.index_by(&:id)
        contests_map = Contest.all.index_by(&:id)
        Submission.includes(:submission_testdata_results).find_in_batches(batch_size: 1024) do |batch|
          data = batch.map do |sub|
            {
              submission_id: sub.id,
              result: sub.calc_subtask_result([
                num_tds_map.fetch(sub.problem_id, 0),
                subtasks_map.fetch(sub.problem_id, []),
                problems_map[sub.problem_id],
                contests_map[sub.contest_id],
              ])
            }
          end
          SubmissionSubtaskResult.import(data)
        end
      end
      direction.down do
      end
    end
  end
end
