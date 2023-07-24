# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  title      :string(255)
#  content    :text(16777215)
#  user_id    :bigint
#  created_at :datetime
#  updated_at :datetime
#  era        :integer
#  pinned     :boolean
#  category   :integer
#  public     :boolean
#
# Indexes
#
#  index_articles_on_category_and_pinned_and_era  (category,pinned,era)
#

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
