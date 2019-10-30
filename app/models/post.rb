# == Schema Information
#
# Table name: posts
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  content        :text(65535)
#  user_id        :integer
#  problem_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  contest_id     :integer
#  global_visible :boolean          default(TRUE), not null
#

class Post < ActiveRecord::Base
  belongs_to :problem
  belongs_to :contest
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
