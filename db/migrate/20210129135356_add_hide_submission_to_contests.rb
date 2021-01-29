class AddHideSubmissionToContests < ActiveRecord::Migration
  def change
	add_column :contests, :hide_old_submission, :boolean, :null => false, :default => false
  end
end
