class AddInterlibToProblems < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :interlib, :text
  end
end
