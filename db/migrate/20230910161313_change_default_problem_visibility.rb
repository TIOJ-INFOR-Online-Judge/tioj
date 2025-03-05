class ChangeDefaultProblemVisibility < ActiveRecord::Migration[7.0]
  def change
    change_column_default :problems, :visible_state, from: 0, to: 2
  end
end
