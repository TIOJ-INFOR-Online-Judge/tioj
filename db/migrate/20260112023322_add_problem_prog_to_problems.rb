class AddProblemProgToProblems < ActiveRecord::Migration[7.2]
  def change
    add_reference :problems, :problem_prog_compiler, foreign_key: { to_table: :compilers }
    add_column :problems, :problem_prog_code, :text
    add_column :problems, :problem_prog_stage_list, :string, null: false, default: ""
  end
end
