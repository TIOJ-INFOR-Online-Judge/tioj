class AddProblemBanCompilerPoly < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :ban_compilers, :contests
    add_reference :ban_compilers, :with_compiler, polymorphic: true
    BanCompiler.update_all("with_compiler_type = 'Contest', with_compiler_id = contest_id")
    remove_index :ban_compilers, column: [:contest_id, :compiler_id]
    remove_column :ban_compilers, :contest_id
    add_index :ban_compilers, [:with_compiler_type, :with_compiler_id, :compiler_id], unique: true, name: :index_ban_compiler_unique
  end
end
