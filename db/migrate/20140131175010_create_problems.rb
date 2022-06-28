class CreateProblems < ActiveRecord::Migration[4.2]
  def change
    create_table :problems do |t|
      t.string :name
      t.text :description
      t.text :source

      t.timestamps
    end
  end
end
