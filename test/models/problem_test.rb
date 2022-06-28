# == Schema Information
#
# Table name: problems
#
#  id             :bigint           not null, primary key
#  name           :string(255)
#  description    :text(16777215)
#  source         :text(16777215)
#  created_at     :datetime
#  updated_at     :datetime
#  input          :text(16777215)
#  output         :text(16777215)
#  example_input  :text(16777215)
#  example_output :text(16777215)
#  hint           :text(16777215)
#  visible_state  :integer          default(0)
#  problem_type   :integer
#  sjcode         :text(4294967295)
#  interlib       :text(4294967295)
#  old_pid        :integer
#

require 'test_helper'

class ProblemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
