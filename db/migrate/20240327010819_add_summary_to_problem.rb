class AddSummaryToProblem < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :summary_type, :integer, :null => false, :default_value => 0
    add_column :problems, :summary_code, :text, size: :long
    add_reference :problems, :summary_compiler, foreign_key: { to_table: :compilers }
  end
end
