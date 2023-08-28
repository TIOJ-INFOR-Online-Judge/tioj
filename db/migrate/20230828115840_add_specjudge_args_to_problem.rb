class AddSpecjudgeArgsToProblem < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :specjudge_compile_args, :string
  end
end
