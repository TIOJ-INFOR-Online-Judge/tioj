# == Schema Information
#
# Table name: announcements
#
#  id         :bigint           not null, primary key
#  title      :string(255)
#  body       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Announcement < ApplicationRecord
end
