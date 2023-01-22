class AddLastCompilerToUser < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :last_compiler, foreign_key: { to_table: :compilers }
  end
end
