class AddExtensionToCompiler < ActiveRecord::Migration[7.0]
  def change
    add_column :compilers, :extension, :string
  end
end
