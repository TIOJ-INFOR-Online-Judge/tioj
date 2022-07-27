# == Schema Information
#
# Table name: contests
#
#  id                  :bigint           not null, primary key
#  title               :string(255)
#  description         :text(16777215)
#  start_time          :datetime
#  end_time            :datetime
#  contest_type        :integer
#  created_at          :datetime
#  updated_at          :datetime
#  cd_time             :integer          default(15), not null
#  disable_discussion  :boolean          default(TRUE), not null
#  freeze_time         :integer          default(0), not null
#  show_detail_result  :boolean          default(TRUE), not null
#  hide_old_submission :boolean          default(FALSE), not null
#

require 'test_helper'

class ContestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
