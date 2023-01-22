class AddTestdatumIdToLimits < ActiveRecord::Migration[4.2]
  def change
    add_column :limits, :testdatum_id, :integer
  end
end
