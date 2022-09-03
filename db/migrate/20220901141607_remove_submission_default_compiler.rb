class RemoveSubmissionDefaultCompiler < ActiveRecord::Migration[7.0]
  def change
    change_column_default :submissions, :compiler_id, nil
  end
end
