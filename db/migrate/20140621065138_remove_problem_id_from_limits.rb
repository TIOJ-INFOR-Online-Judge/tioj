class RemoveProblemIdFromLimits < ActiveRecord::Migration[4.2]
  def change
    remove_column :limits, :problem_id, :integer
  end
end
