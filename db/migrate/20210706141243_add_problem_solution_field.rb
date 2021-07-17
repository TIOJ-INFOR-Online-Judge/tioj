class AddProblemSolutionField < ActiveRecord::Migration
  def change
	add_column :problems, :solution, :text, :limit => 65535
  end
end
