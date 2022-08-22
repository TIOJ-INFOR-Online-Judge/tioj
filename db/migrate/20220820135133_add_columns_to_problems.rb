class AddColumnsToProblems < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :num_stages, :integer, default: 1
    add_column :problems, :judge_between_stages, :boolean, default: false
    add_column :problems, :default_scoring_args, :string
    add_column :problems, :strict_mode, :boolean, default: false
  end
end
