# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  title      :string(255)
#  content    :text(16777215)
#  user_id    :bigint
#  created_at :datetime
#  updated_at :datetime
#  era        :integer
#  pinned     :boolean
#  category   :integer
#  public     :boolean
#
# Indexes
#
#  index_articles_on_category_and_pinned_and_era  (category,pinned,era)
#

class Article < ApplicationRecord
  has_many :attachments, dependent: :destroy
  belongs_to :user
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: lambda { |a| a[:path].blank? }
end
