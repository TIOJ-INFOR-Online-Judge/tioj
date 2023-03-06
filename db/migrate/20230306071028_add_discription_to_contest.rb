class AddDiscriptionToContest < ActiveRecord::Migration[7.0]
  def change
    add_column :contests, :description_before_contest, :mediumtext
    Contest.update_all("description_before_contest = description")
  end
end
