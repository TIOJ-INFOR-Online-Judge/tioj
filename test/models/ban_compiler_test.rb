# == Schema Information
#
# Table name: ban_compilers
#
#  id                 :bigint           not null, primary key
#  compiler_id        :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  with_compiler_type :string(255)
#  with_compiler_id   :bigint
#

require 'test_helper'

class BanCompilerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
