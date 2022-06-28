class AddSjcodeToProblems < ActiveRecord::Migration[4.2]
  def change
    add_column :problems, :sjcode, :text
  end
end
