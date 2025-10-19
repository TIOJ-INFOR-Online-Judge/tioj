class AddTokenToTeam < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :token, :string
  end
end
