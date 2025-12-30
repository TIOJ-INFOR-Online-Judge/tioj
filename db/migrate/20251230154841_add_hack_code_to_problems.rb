class AddHackCodeToProblems < ActiveRecord::Migration[7.2]
  def change
    add_reference :problems, :hackprog_compiler, foreign_key: { to_table: :compilers }
    add_column :problems, :hackprog_code, :text
  end
end
