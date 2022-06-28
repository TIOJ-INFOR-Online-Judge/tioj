class RenameCatagoryToCategoryInArticles < ActiveRecord::Migration[4.2]
  def change
    rename_column :articles, :catagory, :category
  end
end
