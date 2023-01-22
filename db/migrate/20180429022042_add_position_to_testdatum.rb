class AddPositionToTestdatum < ActiveRecord::Migration[4.2]
  def change
    add_column :testdata, :position, :integer
    Problem.all.each do |problem|
        problem.testdata.order(:id).each.with_index(1) do |testdatum, index|
            testdatum.update_column :position, index
        end
    end
  end
end
