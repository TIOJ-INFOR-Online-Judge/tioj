# == Schema Information
#
# Table name: ban_compilers
#
#  id          :bigint           not null, primary key
#  contest_id  :bigint
#  compiler_id :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class BanCompilerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
