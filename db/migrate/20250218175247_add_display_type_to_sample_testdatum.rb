class AddDisplayTypeToSampleTestdatum < ActiveRecord::Migration[7.0]
  def change
    add_column :sample_testdata, :display_type, :integer, null: false, default: 0
  end
end
