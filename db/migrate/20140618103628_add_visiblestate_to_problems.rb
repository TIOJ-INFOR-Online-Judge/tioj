class AddVisiblestateToProblems < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :visible_state, :integer, :default => 0
  end
end
