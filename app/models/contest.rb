# == Schema Information
#
# Table name: contests
#
#  id                 :bigint           not null, primary key
#  title              :string(255)
#  description        :text(16777215)
#  start_time         :datetime
#  end_time           :datetime
#  contest_type       :integer
#  created_at         :datetime
#  updated_at         :datetime
#  cd_time            :integer          default(15), not null
#  disable_discussion :boolean          default(TRUE), not null
#  freeze_time        :integer          not null
#  show_detail_result :boolean          default(TRUE), not null
#

class Contest < ActiveRecord::Base
  has_many :contest_problem_joints, :dependent => :destroy
  has_many :problems, :through => :contest_problem_joints
  has_many :submissions
  has_many :posts

  has_many :ban_compilers, :as => :with_compiler, :dependent => :destroy
  has_many :compilers, :through => :ban_compilers, :as => :with_compiler

  validates :start_time, :presence => true
  validates :end_time, :presence => true
  validates_numericality_of :freeze_time, :greater_than_or_equal_to => 0

  accepts_nested_attributes_for :contest_problem_joints, :reject_if => lambda { |a| a[:problem_id].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :ban_compilers, :allow_destroy => true
end
