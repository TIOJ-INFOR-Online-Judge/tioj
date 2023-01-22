class AddMottoToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :motto, :string
  end
end
