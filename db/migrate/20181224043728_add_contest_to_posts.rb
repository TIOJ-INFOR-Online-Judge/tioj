class AddContestToPosts < ActiveRecord::Migration[4.2]
  def change
    add_reference :posts, :contest, index: true, foreign_key: true
    add_column :posts, :global_visible, :boolean, :null => false, :default => true
  end
end
