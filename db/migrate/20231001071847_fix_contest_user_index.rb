class FixContestUserIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :users, [:type, :nickname]
    remove_index :users, [:type, :username]
    add_index :users, [:type, :contest_id, :nickname], unique: true
    add_index :users, [:type, :contest_id, :email], unique: true
  end
end
