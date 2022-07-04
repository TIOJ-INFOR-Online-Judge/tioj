class AddDiscussionVisibilityToProblems < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :discussion_visibility, :integer, default: 2
  end
end
