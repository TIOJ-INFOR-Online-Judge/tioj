class AddOnlineToJudgeServers < ActiveRecord::Migration[7.0]
  def change
    add_column :judge_servers, :online, :boolean, default: false
  end
end
