class AddOldResults < ActiveRecord::Migration[7.0]
  def change
    create_table :old_submissions do |t|
      t.references :submission, index: {unique: true}
      t.references :problem, index: true
      t.string :result
      t.decimal :score, precision: 18, scale: 6
      t.integer :time
      t.integer :memory

      t.timestamps
    end
    create_table :old_submission_tasks do |t|
      t.references :old_submission, index: true
      t.integer :position
      t.string :result
      t.decimal :score, precision: 18, scale: 6
      t.integer :time
      t.integer :memory

      t.timestamps
    end

    add_index :old_submissions, [:problem_id, :result, :score, :time, :memory], name: :index_old_submissions_topcoder,
      order: {score: :desc, time: :asc, memory: :asc}
  end
end
