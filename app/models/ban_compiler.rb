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
# Indexes
#
#  fk_rails_6b2cbab705                                             (compiler_id)
#  index_ban_compiler_unique                                       (with_compiler_type,with_compiler_id,compiler_id) UNIQUE
#  index_ban_compilers_on_with_compiler_type_and_with_compiler_id  (with_compiler_type,with_compiler_id)
#
# Foreign Keys
#
#  fk_rails_...  (compiler_id => compilers.id)
#

class BanCompiler < ApplicationRecord
  belongs_to :with_compiler, polymorphic: true
  belongs_to :compiler
end
