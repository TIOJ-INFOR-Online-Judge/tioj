class AddCompressedToTestdata < ActiveRecord::Migration[7.0]
  def change
    add_column :testdata, :input_compressed, :boolean, default: false
    add_column :testdata, :output_compressed, :boolean, default: false
  end
end
