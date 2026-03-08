module TeamsHelper
  def member_list_html(users, link, current_user = nil)
    ret = users.map do |user|
      if link
        x = user_link(user, user.username)
      else
        x = user.username
      end
      if user == current_user
        "<strong>#{x}</strong>"
      else
        x
      end
    end
    raw ret.join(", ")
  end
end
