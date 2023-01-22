class CreateSubmissions < ActiveRecord::Migration[4.2]
  def change
    create_table :submissions do |t|
      t.text :code
      t.string :compiler
      t.string :result
      t.integer :score

      t.timestamps
    end
  end
end
