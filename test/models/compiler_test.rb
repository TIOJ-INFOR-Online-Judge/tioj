# == Schema Information
#
# Table name: compilers
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  format_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class CompilerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
