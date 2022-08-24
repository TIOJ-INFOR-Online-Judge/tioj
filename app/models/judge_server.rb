# == Schema Information
#
# Table name: judge_servers
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  ip         :string(255)
#  key        :string(255)
#  created_at :datetime
#  updated_at :datetime
#  online     :boolean          default(FALSE)
#

class JudgeServer < ApplicationRecord
end
