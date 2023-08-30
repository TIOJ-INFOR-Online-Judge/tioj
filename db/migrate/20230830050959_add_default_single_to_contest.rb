class AddDefaultSingleToContest < ActiveRecord::Migration[7.0]
  def change
    add_column :contests, :default_single_contest, :boolean, default: false, null: false
  end
end
