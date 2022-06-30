class OptimizeIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :submissions, column: [:problem_id]
    remove_foreign_key :submissions, :compilers
    remove_index :submissions, column: [:compiler_id]
    remove_index :submissions, column: [:result]
    remove_index :submissions, column: [:total_time, :total_memory], name: 'submissions_sort_ix'
    add_index :submissions, [:contest_id, :problem_id, :result, :score, :total_time, :total_memory], name: :index_submissions_topcoder,
      order: {score: :desc, total_time: :asc, total_memory: :asc}
    add_index :submissions, [:contest_id, :problem_id, :user_id, :result], name: :index_submissions_problem_query
    add_index :submissions, [:contest_id, :user_id, :problem_id, :result], name: :index_submissions_user_query
    add_index :submissions, [:contest_id, :compiler_id, :id], order: {id: :desc}, name: :index_submissions_contest_compiler
    add_index :submissions, [:contest_id, :result, :id], order: {id: :desc}, name: :index_submissions_contest_result
    add_foreign_key :submissions, :compilers
  end
end
