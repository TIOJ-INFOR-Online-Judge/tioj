class RenameAvatarUrlToAvatarInUsers < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :avatar_url, :avatar
  end
end
