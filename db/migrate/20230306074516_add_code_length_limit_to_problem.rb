class AddCodeLengthLimitToProblem < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :code_length_limit, :integer, :default => 5000000
  end
end
