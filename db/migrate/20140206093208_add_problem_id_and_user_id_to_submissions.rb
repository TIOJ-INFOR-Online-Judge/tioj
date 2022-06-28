class AddProblemIdAndUserIdToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :problem_id, :integer
    add_column :submissions, :user_id, :integer
  end
end
