class AllowNonconsecutiveSubtask < ActiveRecord::Migration[4.2]
  def up
    add_column :testdata_sets, :td_list, :string, :null => false
    add_column :testdata_sets, :constraints, :text
    Subtask.update_all('`td_list` = IF(`from` = `to`, `from`, CONCAT(`from`, "-", `to`))')
    remove_column :testdata_sets, :from
    remove_column :testdata_sets, :to
  end
  def down
    add_column :testdata_sets, :from, :integer
    add_column :testdata_sets, :to, :integer
    Subtask.update_all('`from` = SUBSTRING_INDEX(`td_list`, "-", 1), `to` = SUBSTRING_INDEX(`td_list`, "-", -1)')
    remove_column :testdata_sets, :td_list
    remove_column :testdata_sets, :constraints
  end
end
