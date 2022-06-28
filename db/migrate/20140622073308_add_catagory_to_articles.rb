class AddCatagoryToArticles < ActiveRecord::Migration[4.2]
  def change
    add_column :articles, :catagory, :integer
  end
end
