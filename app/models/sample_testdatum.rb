# == Schema Information
#
# Table name: sample_testdata
#
#  id         :integer          not null, primary key
#  problem_id :integer
#  input      :text(16777215)
#  output     :text(16777215)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SampleTestdatum < ActiveRecord::Base
  default_scope { order('id ASC') }

  belongs_to :problem
end
