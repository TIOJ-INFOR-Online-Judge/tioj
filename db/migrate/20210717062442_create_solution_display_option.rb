class CreateSolutionDisplayOption < ActiveRecord::Migration
  def change
	add_column :problems, :display_solution, :boolean, :default => false
  end
end
