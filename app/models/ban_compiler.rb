# == Schema Information
#
# Table name: ban_compilers
#
#  id                 :bigint           not null, primary key
#  compiler_id        :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  with_compiler_type :string(255)
#  with_compiler_id   :bigint
#

class BanCompiler < ActiveRecord::Base
  belongs_to :with_compiler, :polymorphic => true
  belongs_to :compiler
end
