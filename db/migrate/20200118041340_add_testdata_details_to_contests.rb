class AddTestdataDetailsToContests < ActiveRecord::Migration
  def change
	add_column :contests, :show_detail_result, :boolean, :null => false, :default => true
  end
end
