# == Schema Information
#
# Table name: compilers
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  format_type :string(255)
#

class Compiler < ActiveRecord::Base
  has_many :submissions
  has_many :ban_compilers, :dependent => :destroy
  has_many :contests, :through => :ban_compilers
end
