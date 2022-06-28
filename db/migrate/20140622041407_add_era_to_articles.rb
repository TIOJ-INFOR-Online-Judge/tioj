class AddEraToArticles < ActiveRecord::Migration[4.2]
  def change
    add_column :articles, :era, :integer
  end
end
