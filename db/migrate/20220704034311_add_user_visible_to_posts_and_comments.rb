class AddUserVisibleToPostsAndComments < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :user_visible, :boolean, default: false
    add_column :comments, :user_visible, :boolean, default: false
  end
end
