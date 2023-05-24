class AddContestUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :type, :string, null: false, default: "User"
    remove_index :users, column: [:reset_password_token]
    remove_index :users, column: [:username]
    remove_index :users, column: [:nickname]
    remove_index :users, column: [:email]
    add_index :users, [:type, :reset_password_token], unique: true
    add_index :users, [:type, :username], unique: true
    # nickname & email is NULL if it is a ContestUser
    # MySQL allows multiple NULL on unique constraints
    add_index :users, [:type, :nickname], unique: true
    add_index :users, [:type, :email], unique: true
  end
end
