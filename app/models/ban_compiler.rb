# == Schema Information
#
# Table name: ban_compilers
#
#  id          :bigint           not null, primary key
#  contest_id  :bigint
#  compiler_id :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class BanCompiler < ActiveRecord::Base
  belongs_to :with_compiler, :polymorphic => true
  belongs_to :compiler
end
