include SubmissionsHelper

class ChangeCompilerToInt < ActiveRecord::Migration
  def up
    rename_column :submissions, :compiler, :compiler_old
    add_column :submissions, :compiler, :integer, :null => false, :default_value => 0
    compiler_list.map.with_index.each do |x, i|
      Submission.where(compiler_old: x[1]).update_all(compiler: i)
    end
    remove_column :submissions, :compiler_old
  end
  def down
    rename_column :submissions, :compiler, :compiler_old
    add_column :submissions, :compiler, :string, :null => false, :default_value => 'c++14'
    compiler_list.map.with_index.each do |x, i|
      Submission.where(compiler_old: i).update_all(compiler: x[1])
    end
    remove_column :submissions, :compiler_old
  end
end
