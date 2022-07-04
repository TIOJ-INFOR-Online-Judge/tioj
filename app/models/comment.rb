# == Schema Information
#
# Table name: comments
#
#  id           :bigint           not null, primary key
#  title        :string(255)
#  content      :text(16777215)
#  user_id      :bigint
#  post_id      :bigint
#  created_at   :datetime
#  updated_at   :datetime
#  user_visible :boolean          default(FALSE)
#

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  validates_length_of :title, :in => 0..30
  validates_length_of :content, :in => 0..3000
end
