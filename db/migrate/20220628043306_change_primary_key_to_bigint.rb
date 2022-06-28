class ChangePrimaryKeyToBigint < ActiveRecord::Migration[5.2]
  def up
    # Rails 5 use bigint as primary key; thus migrate the old database to ensure compatibility
    remove_foreign_key "ban_compilers", "compilers"
    remove_foreign_key "ban_compilers", "contests"
    remove_foreign_key "posts", "contests"
    remove_foreign_key "submissions", "compilers"

    change_column :active_admin_comments, :id, :bigint, auto_increment: true
    change_column :admin_users, :id, :bigint, auto_increment: true
    change_column :articles, :id, :bigint, auto_increment: true
    change_column :attachments, :id, :bigint, auto_increment: true
    change_column :ban_compilers, :id, :bigint, auto_increment: true
    change_column :comments, :id, :bigint, auto_increment: true
    change_column :compilers, :id, :bigint, auto_increment: true
    change_column :contest_problem_joints, :id, :bigint, auto_increment: true
    change_column :contests, :id, :bigint, auto_increment: true
    change_column :judge_servers, :id, :bigint, auto_increment: true
    change_column :limits, :id, :bigint, auto_increment: true
    change_column :posts, :id, :bigint, auto_increment: true
    change_column :problems, :id, :bigint, auto_increment: true
    change_column :submission_tasks, :id, :bigint, auto_increment: true
    change_column :submissions, :id, :bigint, auto_increment: true
    change_column :taggings, :id, :bigint, auto_increment: true
    change_column :tags, :id, :bigint, auto_increment: true
    change_column :testdata, :id, :bigint, auto_increment: true
    change_column :testdata_sets, :id, :bigint, auto_increment: true
    change_column :users, :id, :bigint, auto_increment: true

    change_column :active_admin_comments, :author_id, :bigint
    change_column :articles, :user_id, :bigint
    change_column :attachments, :article_id, :bigint
    change_column :ban_compilers, :contest_id, :bigint
    change_column :ban_compilers, :compiler_id, :bigint
    change_column :comments, :user_id, :bigint
    change_column :comments, :post_id, :bigint
    change_column :contest_problem_joints, :contest_id, :bigint
    change_column :contest_problem_joints, :problem_id, :bigint
    change_column :limits, :testdatum_id, :bigint
    change_column :posts, :user_id, :bigint
    change_column :posts, :problem_id, :bigint
    change_column :posts, :contest_id, :bigint
    change_column :submission_tasks, :submission_id, :bigint
    change_column :submissions, :problem_id, :bigint
    change_column :submissions, :user_id, :bigint
    change_column :submissions, :contest_id, :bigint
    change_column :submissions, :compiler_id, :bigint
    change_column :taggings, :tag_id, :bigint
    change_column :taggings, :taggable_id, :bigint
    change_column :taggings, :tagger_id, :bigint
    change_column :testdata, :problem_id, :bigint
    change_column :testdata_sets, :problem_id, :bigint

    add_foreign_key "ban_compilers", "compilers"
    add_foreign_key "ban_compilers", "contests"
    add_foreign_key "posts", "contests"
    add_foreign_key "submissions", "compilers"
  end

  def down
  end
end
