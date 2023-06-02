# == Schema Information
#
# Table name: testdata
#
#  id                :bigint           not null, primary key
#  problem_id        :bigint
#  test_input        :string(255)
#  test_output       :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  position          :integer
#  time_limit        :integer          default(1000)
#  vss_limit         :integer          default(65536)
#  rss_limit         :integer
#  output_limit      :integer          default(65536)
#  input_compressed  :boolean          default(FALSE)
#  output_compressed :boolean          default(FALSE)
#

class Testdatum < ApplicationRecord
  belongs_to :problem
  acts_as_list scope: :problem, top_of_list: 0

  mount_uploader :test_input, TestdataUploader
  mount_uploader :test_output, TestdataUploader

  validates :test_input, presence: true
  validates :test_output, presence: true

  validates :time_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :vss_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :rss_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :output_limit, numericality: { greater_than_or_equal_to: 0 }
  validate :vss_or_rss

  def vss_or_rss
    errors.add(:vss_limit, "Either RSS or VSS must be set") unless vss_limit.present? || rss_limit.present?
  end

  # for custom form fields
  attr_accessor :form_same_as_above
  attr_accessor :form_delete

  def timestamp
    updated_at.to_i * 1000000 + updated_at.usec
  end
end
