class AddPinnedToArticles < ActiveRecord::Migration[4.2]
  def change
    add_column :articles, :pinned, :bool
  end
end
