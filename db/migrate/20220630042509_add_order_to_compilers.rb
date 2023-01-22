class AddOrderToCompilers < ActiveRecord::Migration[5.2]
  def change
    add_column :compilers, :order, :integer, index: true
    add_index :compilers, :name, unique: true
  end
end
