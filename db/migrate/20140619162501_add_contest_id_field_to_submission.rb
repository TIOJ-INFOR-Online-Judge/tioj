class AddContestIdFieldToSubmission < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :contest_id, :integer
  end
end
