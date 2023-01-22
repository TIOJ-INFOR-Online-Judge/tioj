class AddDefaultCompiler < ActiveRecord::Migration[4.2]
  def change
    change_column_default :submissions, :compiler_id, 1
  end
end
