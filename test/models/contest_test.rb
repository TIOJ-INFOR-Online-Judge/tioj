# == Schema Information
#
# Table name: contests
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text(65535)
#  start_time         :datetime
#  end_time           :datetime
#  contest_type       :integer
#  created_at         :datetime
#  updated_at         :datetime
#  cd_time            :integer          default(15), not null
#  disable_discussion :boolean          default(TRUE), not null
#  freeze_time        :integer          not null
#

require 'test_helper'

class ContestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
