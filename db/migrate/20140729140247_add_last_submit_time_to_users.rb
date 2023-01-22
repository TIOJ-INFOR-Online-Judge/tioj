class AddLastSubmitTimeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_submit_time, :datetime
  end
end
