class CreateCompilers < ActiveRecord::Migration[4.2]
  def up
    create_table :compilers do |t|
      t.string :name
      t.string :description
      t.string :format_type

      t.timestamps null: false
    end
    rename_column :submissions, :compiler, :compiler_old
    add_column :submissions, :compiler_id, :integer, :null => false, :default_value => 0
    CompilerHelper.generate_table
    Compiler.all.each do |x|
      Submission.where(compiler_old: x.name).update_all(compiler_id: x.id)
    end
    remove_column :submissions, :compiler_old
    add_foreign_key :submissions, :compilers
  end
  def down
    remove_foreign_key :submissions, :compilers
    rename_column :submissions, :compiler_id, :compiler_old
    add_column :submissions, :compiler, :string, :null => false, :default_value => ""
    Compiler.all.each do |x|
      Submission.where(compiler_old: x.id).update_all(compiler: x.name)
    end
    remove_column :submissions, :compiler_old
    drop_table :compilers
  end
end
