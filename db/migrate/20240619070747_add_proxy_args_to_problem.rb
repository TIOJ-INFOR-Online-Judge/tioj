class AddProxyArgsToProblem < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :proxy_judge_type, :string
    add_column :problems, :proxy_judge_args, :text
  end
end
