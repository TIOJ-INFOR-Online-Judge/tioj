class AddSkipGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :skip_group, :boolean, default: false
    add_column :contests, :skip_group, :boolean, default: false
  end
end
