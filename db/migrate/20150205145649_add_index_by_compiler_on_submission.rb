class AddIndexByCompilerOnSubmission < ActiveRecord::Migration[4.2]
  def change
    add_index :submissions, [:compiler]
  end
end
