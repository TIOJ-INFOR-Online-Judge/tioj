class AddMoreInformationToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :school, :string
    add_column :users, :gradyear, :integer
    add_column :users, :name, :string
  end
end
