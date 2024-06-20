class AddProxyArgsToProblem < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :proxyjudge_type, :integer, default: 0
    add_column :problems, :proxyjudge_args, :text, default: ''
  end
end
