# == Schema Information
#
# Table name: roles
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Role < ApplicationRecord
  has_and_belongs_to_many :users, class_name: 'UserBase', association_foreign_key: :user_id


  has_and_belongs_to_many :problems

end
