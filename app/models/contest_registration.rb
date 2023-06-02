# == Schema Information
#
# Table name: contest_registrations
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  contest_id :bigint           not null
#  approved   :boolean          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_contest_registrations_on_contest_id_and_approved  (contest_id,approved)
#  index_contest_registrations_on_contest_id_and_user_id   (contest_id,user_id) UNIQUE
#  index_contest_registrations_on_user_id_and_approved     (user_id,approved)
#

class ContestRegistration < ApplicationRecord
  default_scope { order('id ASC') }

  belongs_to :contest
  belongs_to :user_base, foreign_key: :user_id
end
