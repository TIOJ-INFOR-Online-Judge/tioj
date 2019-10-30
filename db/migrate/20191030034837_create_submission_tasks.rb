class CreateSubmissionTasks < ActiveRecord::Migration
  def change
    create_table :submission_tasks do |t|
      t.integer :submission_id
      t.integer :position
      t.string :result
      t.integer :time
      t.integer :memory
      t.decimal :score, precision: 18, scale: 6

      t.timestamps null: false
    end

    add_index :submission_tasks, :submission_id
    add_index :submission_tasks, [:submission_id, :position], unique: true
  end
end
