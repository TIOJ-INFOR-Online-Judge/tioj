class ChangeScoreToDecimal < ActiveRecord::Migration[4.2]
  def up
    change_column :submissions, :score, :decimal, precision: 18, scale: 6
    change_column :testdata_sets, :score, :decimal, precision: 18, scale: 6
  end
  def down
    #change_column :submissions, :score, :integer
    #change_column :testdata_sets, :score, :integer
  end
end
