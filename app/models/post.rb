# == Schema Information
#
# Table name: posts
#
#  id             :bigint           not null, primary key
#  title          :string(255)
#  content        :text(16777215)
#  user_id        :bigint
#  created_at     :datetime
#  updated_at     :datetime
#  global_visible :boolean          default(TRUE), not null
#  postable_type  :string(255)
#  postable_id    :bigint
#  post_type      :integer          default("discuss")
#  user_visible   :boolean          default(FALSE)
#
# Indexes
#
#  index_post_post_type       (postable_type,post_type)
#  index_post_postable        (postable_type,postable_id)
#  index_posts_on_postable    (postable_type,postable_id)
#  index_posts_on_updated_at  (updated_at)
#  index_posts_on_user_id     (user_id)
#

class Post < ApplicationRecord
  enum :post_type, {discuss: 0, solution: 1, issue: 2}, prefix: :type

  belongs_to :user, class_name: 'UserBase'
  belongs_to :postable, optional: true, polymorphic: true
  has_many :comments, dependent: :destroy

  validates_length_of :title, in: 0..30
  validates_length_of :content, in: 0..65536

  accepts_nested_attributes_for :comments
end
