# == Schema Information
#
# Table name: testdata
#
#  id                :bigint           not null, primary key
#  problem_id        :bigint
#  test_input        :string(255)
#  test_output       :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  position          :integer
#  time_limit        :integer          default(1000)
#  vss_limit         :integer          default(65536)
#  rss_limit         :integer
#  output_limit      :integer          default(65536)
#  input_compressed  :boolean          default(FALSE)
#  output_compressed :boolean          default(FALSE)
#

require 'test_helper'

class TestdatumTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
