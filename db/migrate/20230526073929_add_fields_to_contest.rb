class AddFieldsToContest < ActiveRecord::Migration[7.0]
  def change
    # 0: submit without register
    # 1: needs registration to submit, no approval needed
    # 2: needs registration & approval to submit
    add_column :contests, :register_mode, :integer, null: false, default: 0
    add_column :contests, :register_before, :datetime
    Contest.update_all('register_before = end_time')
    change_column_null :contests, :register_before, false
  end
end
