class RenameColumnOfArticles < ActiveRecord::Migration[4.2]
  def change
    rename_column :articles, :arthur_id, :author_id
  end
end
