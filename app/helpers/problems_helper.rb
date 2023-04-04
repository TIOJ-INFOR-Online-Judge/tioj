module ProblemsHelper
  def topcoder(problem)
    submission = (problem.submissions.select(:user_id)
        .where(contest_id: nil, result: 'AC')
        .order(score: :desc, total_time: :asc, total_memory: :asc, code_length: :asc, id: :asc)).first
    return User.find_by_id(submission.user_id) if submission
    return nil if submission.blank?
  end

  def topcoders(problems)
    topcoder_clause = (Submission.select(:user_id)
        .where(contest_id: nil, result: 'AC').where('problem_id = problems.id')
        .order(score: :desc, total_time: :asc, total_memory: :asc, code_length: :asc, id: :asc)
        .limit(1).to_sql)
    problem_ids = problems.map(&:id)
    lst = Problem.select(:id, "(#{topcoder_clause}) topcoder").where(id: problem_ids).to_a
    topcoders = User.where(id: lst.map(&:topcoder).compact.uniq).index_by(&:id)
    topcoders_mp = lst.collect { |prob| [prob.id, prob.topcoder ? topcoders[prob.topcoder] : nil] }.to_h
    return topcoders_mp
  end

  def ratio_text(ac, all)
    return "%.1f%%" % (100.0 * ac / all)
  end

  def users_ac_ratio(problem)
    all = problem.submissions.select('COUNT(DISTINCT user_id) cnt').where(contest_id: nil).first.cnt
    ac = problem.submissions.select('COUNT(DISTINCT user_id) cnt').where(contest_id: nil, result: 'AC').first.cnt
    ranklist_page = link_to ac.to_s + "/" + all.to_s, ranklist_problem_path(problem.id)
    return raw ( ratio_text(ac, all) + " (" + ranklist_page + ")" )
  end

  def submissions_ac_ratio(problem)
    all = problem.submissions.where(contest_id: nil)
    ac = all.where(result: 'AC').count
    all = all.count
    ac_page = link_to ac, :controller => :submissions, :action => :index, :problem_id => problem.id, :filter_status => "AC"
    all_page = link_to all, problem_submissions_path(problem.id)
    return raw ( ratio_text(ac, all) + " (" + ac_page + "/" + all_page + ")" )
  end

  def users_ac_ratio_with_infor(problem, attr_map)
    all = attr_map[problem.id].user_cnt
    ac = attr_map[problem.id].user_ac
    ranklist_page = link_to ac.to_s + "/" + all.to_s, ranklist_problem_path(problem.id)
    return raw ( ratio_text(ac, all) + " (" + ranklist_page + ")" )
  end

  def submissions_ac_ratio_with_infor(problem, attr_map)
    all = attr_map[problem.id].sub_cnt
    ac = attr_map[problem.id].sub_ac
    ac_page = link_to ac, :controller => :submissions, :action => :index, :problem_id => problem.id, :filter_status => "AC"
    all_page = link_to all, problem_submissions_path(problem.id)
    return raw ( ratio_text(ac, all) + " (" + ac_page + "/" + all_page + ")" )
  end

  def user_problem_status(user, problem)
    if user_problem_ac(user, problem)
      raw '<span class="text-success glyphicon glyphicon-ok"></span>'
    elsif user_problem_tried(user, problem)
      raw '<span class="text-danger glyphicon glyphicon-thumbs-down"></span>'
    else
      raw '<span class="text-muted glyphicon glyphicon-minus"></span>'
    end
  end

  def user_problem_status_with_infor(problem, attr_map)
    if attr_map[problem.id].cur_user_ac > 0
      raw '<span class="text-success glyphicon glyphicon-ok"></span>'
    elsif attr_map[problem.id].cur_user_tried > 0
      raw '<span class="text-danger glyphicon glyphicon-thumbs-down"></span>'
    else
      raw '<span class="text-muted glyphicon glyphicon-minus"></span>'
    end
  end

  def tag_list_html(problem)
    raw (problem.tags.map{ |a| link_to a, problems_tag_path(a.name), :class => 'btn btn-xs btn-default' } +
         problem.solution_tags.map{ |a| link_to a, problems_tag_path(a.name), :class => 'btn btn-xs btn-warning solution-tag no-display' }).join(" ")
  end

  def specjudge_type_desc_map
    {
      "none" => "Default compare",
      "old" => "Old-style special judge",
      "new" => "New-style special judge",
    }
  end

  def interlib_type_desc_map
    {
      "none" => "No interactive library",
      "header" => "With interactive library",
    }
  end

  def discussion_visibility_desc_map
    {
      "disabled" => "No discussion",
      "readonly" => "Read admin posts only",
      "enabled" => "Allow discussion",
    }
  end
end
