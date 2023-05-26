class AddContestUserContestId < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :contest, foreign_key: true
    change_column_null :users, :email, true
    change_column_default :users, :email, nil
  end
end
