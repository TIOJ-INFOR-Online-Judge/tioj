class ChangeUsernameToUnique < ActiveRecord::Migration[4.2]
  def change
    add_index :users, :nickname, unique: true
  end
end
