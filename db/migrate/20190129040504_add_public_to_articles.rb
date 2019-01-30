class AddPublicToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :public, :boolean
  end
end
