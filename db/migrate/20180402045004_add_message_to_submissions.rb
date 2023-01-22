class AddMessageToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :message, :text
  end
end
