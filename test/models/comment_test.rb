# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  title      :string(255)
#  content    :text(16777215)
#  user_id    :bigint
#  post_id    :bigint
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
