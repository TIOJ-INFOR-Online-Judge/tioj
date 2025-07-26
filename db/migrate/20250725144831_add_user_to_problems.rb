class AddUserToProblems < ActiveRecord::Migration[7.2]
  def change
    add_reference :problems, :user, null: false, foreign_key: true, default: 1
  end
end
