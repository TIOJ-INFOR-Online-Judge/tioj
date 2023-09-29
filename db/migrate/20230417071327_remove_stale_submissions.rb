class RemoveStaleSubmissions < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      direction.up do
        Submission.where.not(contest_id: [nil] + Contest.ids).update_all(contest_id: nil)
      end
      direction.down do
      end
    end
  end
end
