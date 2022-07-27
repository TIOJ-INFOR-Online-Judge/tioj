class AddContestUsernameWhitelist < ActiveRecord::Migration[7.0]
  def change
    add_column :contests, :user_whitelist, :text
  end
end
