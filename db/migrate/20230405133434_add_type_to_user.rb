class AddTypeToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_type, :integer, default: 5
    
    reversible do |direction|
      direction.up do
        execute "UPDATE users SET user_type = admin * 5 + 5"
      end
      direction.down do
        execute "UPDATE users SET admin = (user_type = 10)"
      end
    end

    remove_column :users, :admin, :boolean
    add_index :users, :user_type
  end
end
