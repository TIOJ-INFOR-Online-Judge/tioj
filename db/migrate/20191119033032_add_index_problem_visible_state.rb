class AddIndexProblemVisibleState < ActiveRecord::Migration
  def change
    add_index :problems, :visible_state
  end
end
