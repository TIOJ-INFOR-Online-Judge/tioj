class AlterSubmissionsIndex < ActiveRecord::Migration[4.2]
  def change
    remove_index :submissions, :name => "submissions_index"
  end
end
