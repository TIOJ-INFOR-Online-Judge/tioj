# == Schema Information
#
# Table name: limits
#
#  id           :bigint           not null, primary key
#  time         :integer          default(1000)
#  vss          :integer          default(65536)
#  output       :integer          default(65536)
#  created_at   :datetime
#  updated_at   :datetime
#  testdatum_id :bigint
#  rss          :integer
#

require 'test_helper'

class LimitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
