class AddProblemIdToTestdata < ActiveRecord::Migration[4.2]
  def change
    add_column :testdata, :problem_id, :integer
  end
end
