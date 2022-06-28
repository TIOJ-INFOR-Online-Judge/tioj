class AddResultToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :_result, :string
  end
end
