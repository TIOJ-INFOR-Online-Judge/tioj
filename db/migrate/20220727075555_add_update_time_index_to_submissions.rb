class AddUpdateTimeIndexToSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_index :submissions, [:result, :updated_at]
  end
end
