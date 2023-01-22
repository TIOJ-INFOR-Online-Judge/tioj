class AddPostTypeToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :post_type, :integer, default: 0
    add_index :posts, [:postable_type, :post_type], name: :index_post_post_type
  end
end
