class AddPublicToArticles < ActiveRecord::Migration[4.2]
  def change
    add_column :articles, :public, :boolean
  end
end
