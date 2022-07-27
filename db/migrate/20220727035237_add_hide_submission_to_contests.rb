class AddHideSubmissionToContests < ActiveRecord::Migration[7.0]
  def change
    add_column :contests, :hide_old_submission, :boolean, :null => false, :default => false
  end
end
