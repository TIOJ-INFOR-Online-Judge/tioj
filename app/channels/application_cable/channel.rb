module ApplicationCable
  class Channel < ActionCable::Channel::Base
    include ApplicationHelper

    def effective_admin?
      current_user&.admin && !is_single_contest
    end
  end
end
