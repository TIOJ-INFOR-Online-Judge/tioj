class AddScorePrecisionToProblems < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :score_precision, :integer, default: 2
  end
end
