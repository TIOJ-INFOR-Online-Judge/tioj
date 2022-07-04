class AddInterlibImplToProblems < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :interlib_impl, :text, size: :long
  end
end
