class AddVerdictIgnoreListToProblems < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :verdict_ignore_td_list, :string, null: false
  end
end
