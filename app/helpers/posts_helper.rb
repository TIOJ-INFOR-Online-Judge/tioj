module PostsHelper
  def post_user(post)
    ret = case
      when post.user == nil then 'deleted account'
      when !effective_admin? && !post.user_visible && current_user&.id != post.user_id then 'anonymous'
      else user_link(post.user, post.user.username)
    end
    ret + " - #{post.created_at.to_fs(:clean)}"
  end

  def post_bg_class(post, contest, problem)
    if (contest and post.global_visible) or (problem and post.post_type == 'solution')
      "bg-warning-subtle"
    else
      "bg-light"
    end
  end
end
