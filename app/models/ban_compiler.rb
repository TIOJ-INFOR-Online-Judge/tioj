# == Schema Information
#
# Table name: ban_compilers
#
#  id          :integer          not null, primary key
#  contest_id  :integer
#  compiler_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class BanCompiler < ActiveRecord::Base
  belongs_to :contest
  belongs_to :compiler
end
