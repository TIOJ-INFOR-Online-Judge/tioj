# == Schema Information
#
# Table name: testdata_sets
#
#  id         :integer          not null, primary key
#  problem_id :integer
#  from       :integer
#  to         :integer
#  score      :decimal(18, 6)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class TestdataSetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
