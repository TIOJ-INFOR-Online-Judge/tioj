module TeamsHelper
  def member_list_html(users, link)
    ret = users.map do |user|
      if link
        user_link(user, user.username)
      else
        user.username
      end
    end
    raw ret.join(", ")
  end
end
