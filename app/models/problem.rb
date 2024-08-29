# == Schema Information
#
# Table name: problems
#
#  id                     :bigint           not null, primary key
#  name                   :string(255)
#  description            :text(16777215)
#  source                 :text(16777215)
#  created_at             :datetime
#  updated_at             :datetime
#  input                  :text(16777215)
#  output                 :text(16777215)
#  hint                   :text(16777215)
#  visible_state          :integer          default("invisible")
#  sjcode                 :text(4294967295)
#  interlib               :text(4294967295)
#  specjudge_type         :integer          not null
#  interlib_type          :integer          not null
#  specjudge_compiler_id  :bigint
#  discussion_visibility  :integer          default("enabled")
#  interlib_impl          :text(4294967295)
#  score_precision        :integer          default(2)
#  verdict_ignore_td_list :string(255)      not null
#  num_stages             :integer          default(1)
#  judge_between_stages   :boolean          default(FALSE)
#  default_scoring_args   :string(255)
#  strict_mode            :boolean          default(FALSE)
#  skip_group             :boolean          default(FALSE)
#  ranklist_display_score :boolean          default(FALSE)
#  code_length_limit      :integer          default(5000000)
#  specjudge_compile_args :string(255)
#  summary_type           :integer          not null
#  summary_code           :text(4294967295)
#  summary_compiler_id    :bigint
#  proxyjudge_type        :integer          default("none"), not null
#  proxyjudge_args        :string(255)
#
# Indexes
#
#  index_problems_on_name                   (name)
#  index_problems_on_specjudge_compiler_id  (specjudge_compiler_id)
#  index_problems_on_summary_compiler_id    (summary_compiler_id)
#  index_problems_on_visible_state          (visible_state)
#
# Foreign Keys
#
#  fk_rails_...  (specjudge_compiler_id => compilers.id)
#  fk_rails_...  (summary_compiler_id => compilers.id)
#

class Problem < ApplicationRecord
  enum :visible_state, {public: 0, contest: 1, invisible: 2}, prefix: :visible
  enum :specjudge_type, {none: 0, old: 1, new: 2}, prefix: :specjudge
  enum :interlib_type, {none: 0, header: 1}, prefix: :interlib
  enum :summary_type, {none: 0, custom: 1}, prefix: :summary
  enum :discussion_visibility, {disabled: 0, readonly: 1, enabled: 2}, prefix: :discussion
  enum :proxyjudge_type, {
    none: 0,
    codeforces: 1,
    poj: 2,
    qoj: 3,
  }, prefix: :proxyjudge

  acts_as_taggable_on :tags, :solution_tags

  has_many :submissions, dependent: :destroy
  has_many :old_submissions, dependent: :destroy

  has_many :contest_problem_joints, dependent: :destroy
  has_many :contests, through: :contest_problem_joints

  has_many :ban_compilers, as: :with_compiler, dependent: :destroy
  has_many :compilers, through: :ban_compilers, as: :with_compiler

  has_many :testdata, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :testdata, allow_destroy: true, reject_if: :all_blank

  has_many :subtasks, dependent: :delete_all
  accepts_nested_attributes_for :subtasks, allow_destroy: true, reject_if: :all_blank

  has_many :posts, as: :postable, dependent: :destroy
  accepts_nested_attributes_for :posts, allow_destroy: true, reject_if: :all_blank

  has_many :sample_testdata, dependent: :destroy
  accepts_nested_attributes_for :sample_testdata, allow_destroy: true, reject_if: :all_blank

  belongs_to :specjudge_compiler, class_name: 'Compiler', optional: true
  belongs_to :summary_compiler, class_name: 'Compiler', optional: true

  validates_length_of :sjcode, maximum: 5000000
  validates_length_of :interlib, maximum: 5000000
  validates_length_of :interlib_impl, maximum: 5000000
  validates_length_of :summary_code, maximum: 5000000

  validates :code_length_limit, numericality: { in: 1..16777216 }

  validates :score_precision, numericality: { in: 0..6 }
  validates :num_stages, numericality: { in: 1..10 }

  def judge_between_stages_only_if_specjudge
    if specjudge_none? and judge_between_stages
      errors.add(:judge_between_stages, "Can only judge between stages when using special judge")
    end
  end

  def proxyjudge_any?
    not proxyjudge_none?
  end
end
