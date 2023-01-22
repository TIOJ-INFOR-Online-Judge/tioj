class ChangeResultToString < ActiveRecord::Migration[4.2]
  def change
    change_column :submissions, :_result, :text, :limit => 10000
  end
end
