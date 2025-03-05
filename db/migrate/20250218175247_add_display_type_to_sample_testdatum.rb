class AddDisplayTypeToSampleTestdatum < ActiveRecord::Migration[7.0]
  def change
    add_column :sample_testdata, :display_type, :integer, null: false, default: 0
    SampleTestdatum.where(
      "input LIKE ? OR input LIKE ? OR input LIKE ? OR input LIKE ? OR
       output LIKE ? OR output LIKE ? OR output LIKE ? OR output LIKE ?",
       '%$%$%', '%\\(%\\)%', '%\\\\[%\\\\]%', '%<%>%',
       '%$%$%', '%\\(%\\)%', '%\\\\[%\\\\]%', '%<%>%'
    ).update_all(display_type: 1)
  end
end
