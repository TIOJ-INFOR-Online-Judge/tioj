class AddMessageToSubmissionTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_tasks, :message_type, :string
    add_column :submission_tasks, :message, :text, size: :medium
  end
end
