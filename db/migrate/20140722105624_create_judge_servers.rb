class CreateJudgeServers < ActiveRecord::Migration[4.2]
  def change
    create_table :judge_servers do |t|
      t.string :name
      t.string :ip
      t.string :key

      t.timestamps
    end
  end
end
