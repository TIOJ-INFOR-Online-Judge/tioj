class ChangePostToPolymorphism < ActiveRecord::Migration[7.0]
  def up
    add_reference :posts, :postable, polymorphic: true
    Post.where.not(problem_id: nil).update_all("postable_type = 'Problem', postable_id = problem_id")
    Post.where.not(contest_id: nil).update_all("postable_type = 'Contest', postable_id = contest_id")
    remove_foreign_key :posts, :contests
    remove_index :posts, column: [:contest_id]
    remove_column :posts, :problem_id
    remove_column :posts, :contest_id
    add_index :posts, [:postable_type, :postable_id], name: :index_post_postable
  end
end
