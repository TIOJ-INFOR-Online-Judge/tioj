class AddNewColumnsToUsers < ActiveRecord::Migration[4.2]
  def change
	add_column :users,  :nickname, :string
	add_column :users, :avatar_url, :string
  end
end
