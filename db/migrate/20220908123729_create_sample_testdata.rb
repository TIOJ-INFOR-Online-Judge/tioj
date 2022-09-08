class CreateSampleTestdata < ActiveRecord::Migration[7.0]
  def change
    create_table :sample_testdata do |t|
      t.references :problem
      t.text :input, size: :medium
      t.text :output, size: :medium

      t.timestamps
    end
  end
end
