# == Schema Information
#
# Table name: testdata_sets
#
#  id          :bigint           not null, primary key
#  problem_id  :bigint
#  score       :decimal(18, 6)
#  created_at  :datetime
#  updated_at  :datetime
#  td_list     :string(255)      not null
#  constraints :text(16777215)
#

class TestdataSet < ActiveRecord::Base
  belongs_to :problem
end
