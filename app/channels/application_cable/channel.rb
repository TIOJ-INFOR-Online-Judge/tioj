module ApplicationCable
  class Channel < ActionCable::Channel::Base
    include ApplicationHelper

    def effective_admin?
      current_user&.admin? && single_contest.nil?
    end
  end
end
