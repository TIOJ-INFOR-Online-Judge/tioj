class AddContestUsernameWhitelist < ActiveRecord::Migration
  def change
	add_column :contests, :user_whitelist, :text
  end
end
