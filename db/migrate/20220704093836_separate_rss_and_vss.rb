class SeparateRssAndVss < ActiveRecord::Migration[7.0]
  def up
    rename_column :limits, :memory, :vss
    add_column :limits, :rss, :integer
    rename_column :submission_tasks, :memory, :rss
    add_column :submission_tasks, :vss, :integer
    change_column :submission_tasks, :time, :decimal, precision: 12, scale: 3
  end
end
