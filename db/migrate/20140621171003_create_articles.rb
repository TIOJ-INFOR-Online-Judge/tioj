class CreateArticles < ActiveRecord::Migration[4.2]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.integer :arthur_id
      
      t.timestamps
    end
  end
end
