class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :teamname

      t.string :avatar
      t.string :motto
      t.string :school

      t.timestamps
    end
  end
end
