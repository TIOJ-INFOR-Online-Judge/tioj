class CreateContests < ActiveRecord::Migration[4.2]
  def change
    create_table :contests do |t|
      t.string :title		#contest title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.integer :contest_type	#acm, ioi...
      
      t.timestamps
    end
    
  end
end
