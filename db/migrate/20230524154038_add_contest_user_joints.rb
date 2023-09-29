class AddContestUserJoints < ActiveRecord::Migration[7.0]
  def change
    create_table :contest_user_joints do |t|
      t.references :user, index: false, null: false
      t.references :contest, index: false, null: false
      t.boolean :approved, null: false

      t.timestamps
    end
    add_index :contest_user_joints, [:contest_id, :approved]
    add_index :contest_user_joints, [:user_id, :approved]
    add_index :contest_user_joints, [:contest_id, :user_id], unique: true
  end
end
