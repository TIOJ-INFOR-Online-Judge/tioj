class AddTestdataDetailsToContests < ActiveRecord::Migration[4.2]
  def change
    add_column :contests, :show_detail_result, :boolean, :null => false, :default => true
  end
end
