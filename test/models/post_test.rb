# == Schema Information
#
# Table name: posts
#
#  id             :bigint           not null, primary key
#  title          :string(255)
#  content        :text(16777215)
#  user_id        :bigint
#  problem_id     :bigint
#  created_at     :datetime
#  updated_at     :datetime
#  contest_id     :bigint
#  global_visible :boolean          default(TRUE), not null
#

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
