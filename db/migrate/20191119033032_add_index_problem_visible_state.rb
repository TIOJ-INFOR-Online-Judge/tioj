class AddIndexProblemVisibleState < ActiveRecord::Migration[4.2]
  def change
    add_index :problems, :visible_state
  end
end
