class AddDefaultCompiler < ActiveRecord::Migration
  def change
    change_column_default :submissions, :compiler_id, 1
  end
end
