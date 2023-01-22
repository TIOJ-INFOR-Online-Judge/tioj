class AddTypesToProblems < ActiveRecord::Migration[5.2]
  def up
    default_compiler_id = Compiler.where(name: 'c++14').first.id
    add_column :problems, :specjudge_type, :integer, :null => false, :default_value => 0
    add_column :problems, :interlib_type, :integer, :null => false, :default_value => 0
    add_reference :problems, :specjudge_compiler, foreign_key: { to_table: :compilers }
    Problem.where(problem_type: 0).update_all(specjudge_type: 0, interlib_type: 0)
    Problem.where(problem_type: 1).update_all(specjudge_type: 1, interlib_type: 0, specjudge_compiler_id: default_compiler_id)
    Problem.where(problem_type: 2).update_all(specjudge_type: 0, interlib_type: 1)
    remove_column :problems, :problem_type
  end
end
