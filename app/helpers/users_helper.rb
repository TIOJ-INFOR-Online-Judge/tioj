module UsersHelper
  def ac_ratio_by_user(user)
    all = user.submissions.where(contest_id: nil).select(:result)
    ac = all.where(result: 'AC').count
    all = all.count
    ac_page = link_to ac, submissions_path(filter_user_id: user.id, :'filter_status[]' => "AC")
    all_page = link_to all, submissions_path(filter_user_id: user.id)
    return raw ( ratio_text(ac, all) + " (" + ac_page + "/" + all_page + ")" )
  end

  def ac_ratio_by_user_with_infor(user)
    ac_page = link_to user.acsub, submissions_path(filter_user_id: user.id, :'filter_status[]' => "AC")
    all_page = link_to user.sub, submissions_path(filter_user_id: user.id)
    return raw ( ratio_text(user.acsub, user.sub) + " (" + ac_page + "/" + all_page + ")" )
  end

  def user_problem_ac(user, problem)
    return Submission.exists?(contest_id: nil, user_id: user.id, problem_id: problem.id, result: "AC")
  end

  def user_problem_tried(user, problem)
    return Submission.exists?(contest_id: nil, user_id: user.id, problem_id: problem.id)
  end

  def user_link(user, content)
    case
      when @layout == :single_contest then content
      when user.type != 'ContestUser' then link_to(content, user_path(user))
      when current_user&.admin? then link_to(content, contest_contest_registrations_path(user.contest_id))
      else content
    end
  end
end
