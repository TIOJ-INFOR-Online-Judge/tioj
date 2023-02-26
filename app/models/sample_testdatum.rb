# == Schema Information
#
# Table name: sample_testdata
#
#  id         :bigint           not null, primary key
#  problem_id :bigint
#  input      :text(16777215)
#  output     :text(16777215)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SampleTestdatum < ActiveRecord::Base
  default_scope { order('id ASC') }

  belongs_to :problem
end
