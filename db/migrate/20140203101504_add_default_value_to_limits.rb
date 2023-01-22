class AddDefaultValueToLimits < ActiveRecord::Migration[4.2]
  def change
    change_column :limits, :time, :integer, :default => 1000
    change_column :limits, :memory, :integer, :default => 65536
    change_column :limits, :output, :integer, :default => 65536
  end
end
