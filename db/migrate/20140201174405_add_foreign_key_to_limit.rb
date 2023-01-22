class AddForeignKeyToLimit < ActiveRecord::Migration[4.2]
  def change
    add_column :limits, :problem_id, :integer
  end
end
