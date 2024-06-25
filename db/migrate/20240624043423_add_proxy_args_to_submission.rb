class AddProxyArgsToSubmission < ActiveRecord::Migration[7.0]
  def change
    add_column :submissions, :proxyjudge_type, :integer, null: false, default: 0, index: true
    add_column :submissions, :proxyjudge_nonce, :string
    add_column :submissions, :proxyjudge_id, :string
    remove_index :submissions, [:result, :priority, :id], name: :index_submissions_fetch
    add_index :submissions, [:proxyjudge_type, :result, :priority, :id], order: {priority: :desc}, name: :index_submissions_fetch
  end
end
