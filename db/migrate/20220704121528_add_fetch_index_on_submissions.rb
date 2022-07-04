class AddFetchIndexOnSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_index :submissions, [:result, :contest_id, :id], name: :index_submissions_fetch
  end
end
