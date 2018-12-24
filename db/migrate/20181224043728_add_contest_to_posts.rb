class AddContestToPosts < ActiveRecord::Migration
  def change
    add_reference :posts, :contest, index: true, foreign_key: true
    add_column :posts, :global_visible, :boolean, :null => false, :default => true
  end
end
