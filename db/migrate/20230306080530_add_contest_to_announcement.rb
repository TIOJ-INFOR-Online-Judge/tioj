class AddContestToAnnouncement < ActiveRecord::Migration[7.0]
  def change
    add_reference :announcements, :contest, foreign_key: true
  end
end
