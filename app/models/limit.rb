# == Schema Information
#
# Table name: limits
#
#  id           :bigint           not null, primary key
#  time         :integer          default(1000)
#  vss          :integer          default(65536)
#  output       :integer          default(65536)
#  created_at   :datetime
#  updated_at   :datetime
#  testdatum_id :bigint
#  rss          :integer
#

class Limit < ApplicationRecord
  belongs_to :testdatum

  validates :time, :numericality => { :greater_than_or_equal_to => 0 }
  validates :vss, :numericality => { :greater_than_or_equal_to => 0 }, allow_nil: true
  validates :rss, :numericality => { :greater_than_or_equal_to => 0 }, allow_nil: true
  validates :output, :numericality => { :greater_than_or_equal_to => 0 }
  validate :vss_or_rss

  def vss_or_rss
    errors.add(:vss, "Either RSS or VSS must be set") unless vss.present? || rss.present?
  end
end
