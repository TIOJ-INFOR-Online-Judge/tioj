class AddShowRankToRoles < ActiveRecord::Migration[7.2]
  def change
    add_column :roles, :show_rank, :boolean, default: false, null: false
  end
end
