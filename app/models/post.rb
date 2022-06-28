# == Schema Information
#
# Table name: posts
#
#  id             :bigint           not null, primary key
#  title          :string(255)
#  content        :text(16777215)
#  user_id        :bigint
#  problem_id     :bigint
#  created_at     :datetime
#  updated_at     :datetime
#  contest_id     :bigint
#  global_visible :boolean          default(TRUE), not null
#

class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :problem, optional: true
  belongs_to :contest, optional: true
  has_many :comments, dependent: :destroy

  validates_length_of :title, :in => 0..30
  validates_length_of :content, :in => 0..3000

  def problem_or_contest?
    if not problem.nil? and not contest.nil?
      errors.add(:base, 'Posts cannot belong to both problems and contests')
    end
  end

  accepts_nested_attributes_for :comments
end
