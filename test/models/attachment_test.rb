# == Schema Information
#
# Table name: attachments
#
#  id         :bigint           not null, primary key
#  article_id :bigint
#  path       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_attachments_on_article_id  (article_id)
#

require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
