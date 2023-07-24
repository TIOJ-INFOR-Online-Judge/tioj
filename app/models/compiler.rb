# == Schema Information
#
# Table name: compilers
#
#  id          :bigint           not null, primary key
#  name        :string(255)
#  description :string(255)
#  format_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  order       :integer
#
# Indexes
#
#  index_compilers_on_name  (name) UNIQUE
#

class Compiler < ApplicationRecord
  has_many :submissions
  has_many :ban_compilers, :dependent => :destroy
  has_many :contests, :through => :ban_compilers
end
