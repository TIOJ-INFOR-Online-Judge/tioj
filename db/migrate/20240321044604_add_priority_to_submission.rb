class AddPriorityToSubmission < ActiveRecord::Migration[7.0]
  def change
    add_column :submissions, :priority, :integer, default: 20, null: false
    remove_index :submissions, [:result, :contest_id, :id], name: :index_submissions_fetch
    add_index :submissions, [:result, :priority, :id], order: {priority: :desc}, name: :index_submissions_fetch
    reversible do |direction|
      direction.up do
        Submission.where.not(contest_id: nil).update_all(priority: 40)
      end
    end
  end
end
