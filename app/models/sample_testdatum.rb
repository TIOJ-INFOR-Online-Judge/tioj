# == Schema Information
#
# Table name: sample_testdata
#
#  id           :bigint           not null, primary key
#  problem_id   :bigint
#  input        :text(16777215)
#  output       :text(16777215)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  display_type :integer          default("plaintext"), not null
#
# Indexes
#
#  index_sample_testdata_on_problem_id  (problem_id)
#

class SampleTestdatum < ActiveRecord::Base
  default_scope { order('id ASC') }

  belongs_to :problem
  enum :display_type, {plaintext: 0, markdown: 1}, prefix: :display
end
