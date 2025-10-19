module ContestsHelper
  def contest_type_desc_map
    {
      "ioi" => "IOI style (rank by score)",
      "ioi_new" => "New IOI style (rank by score, union by subtasks)",
      "acm" => "ACM style (rank by solved problems)",
    }
  end

  def contest_type_short_desc_map
    {
      "ioi" => "IOI",
      "ioi_new" => "New IOI",
      "acm" => "ACM",
    }
  end

  def register_mode_desc_map
    {
      "no_register" => "No registration required",
      "free_register" => "Registration required, no approval needed",
      "require_approval" => "Registration and approval required",
    }
  end

  private

  def submission_rel_timestamp(submission, start_time)
    submission.created_at_usec - to_us(start_time)
  end

  # return item_state
  def acm_ranklist_state(submission, start_time, item_state, is_waiting)
    # state: [attempts, ac_usec, waiting]
    if item_state.nil?
      item_state = [0, nil, 0]
    end
    return nil if not item_state[1].nil?
    item_state = item_state.dup
    if is_waiting
      item_state[2] += 1
    else
      item_state[0] += 1
      if submission.result == 'AC'
        item_state[1] = submission_rel_timestamp(submission, start_time)
        item_state[2] = 0
      end
    end
    item_state
  end

  def ioi_ranklist_state(submission, start_time, item_state, is_waiting)
    # state: [score, has_sub, waiting]
    if item_state.nil?
      item_state = [BigDecimal(0), false, 0]
    end
    if is_waiting
      item_state = item_state.dup
      item_state[2] += 1
      item_state
    else
      item_state[0] >= submission.score && item_state[1] ? nil : [submission.score, true, item_state[2]]
    end
  end

  def ioi_new_ranklist_state(submission, start_time, item_state, is_waiting)
    # state: [score, has_sub, waiting, subtask_scores]
    if item_state.nil?
      item_state = [BigDecimal(0), false, 0, nil]
    end
    item_state = item_state.dup
    if is_waiting
      item_state[2] += 1
      item_state
    else
      scores = submission.get_subtask_result.map{|x| x[:score]}
      if item_state[3].nil?
        item_state[3] = scores
      else
        item_state[3] = item_state[3].zip(scores).map(&:max)
      end
      nscore = item_state[3].sum
      item_state[0] >= nscore && item_state[1] ? nil : [nscore, true, item_state[2], item_state[3]]
    end
  end

  public

  def ranklist_data(submissions, start_time, freeze_start, rule, user_team_mapping)
    res = Hash.new { |h, k| h[k] = [] }
    participants = Set[]
    teams = Set[]
    func = {
      'acm' => method(:acm_ranklist_state),
      'ioi' => method(:ioi_ranklist_state),
      'ioi_new' => method(:ioi_new_ranklist_state),
    }[rule]
    first_ac = {}
    submissions = submissions.to_a
    submissions.each do |sub|
      team_id = user_team_mapping[sub.user_id]
      if team_id.nil?
        effective_id = "user_#{sub.user_id}"
        participants << sub.user_id
      else
        effective_id = "team_#{team_id}"
        teams << team_id
      end
      next if ['CE', 'ER', 'CLE', 'JE'].include?(sub.result) && sub.created_at < freeze_start
      key = "#{effective_id}_#{sub.problem_id}"
      is_waiting = ['queued', 'received', 'Validating'].include?(sub.result) || sub.created_at >= freeze_start
      orig_state = res[key][-1]&.dig(:state)
      new_state = func.call(sub, start_time, orig_state, is_waiting)
      res[key] << {timestamp: submission_rel_timestamp(sub, start_time), state: new_state} unless new_state.nil?
      first_ac[sub.problem_id] = first_ac.fetch(sub.problem_id, effective_id) if sub.result == 'AC' && sub.created_at < freeze_start
    end
    res.delete_if { |key, value| value.empty? }
    res.each_value {|x| x.each {|item| item[:state].pop}} if rule == 'ioi_new'
    {result: res, participants: participants.to_a, teams: teams.to_a, first_ac: first_ac}
  end

  def problem_index_text(index)
    text = ''
    while index >= 26
      text = (65 + index % 26).chr + text
      index = index / 26 - 1
    end
    return 'p' + (65 + index % 26).chr + text
  end

  ## --- HTML ---

  def contest_registration_page_button(contest, status, standalone)
    if contest.can_register?
      btn_class = standalone ? 'btn-lg' : 'btn-xs'
      btn_class += ' btn-primary'
      button_text = standalone ? 'Change Registration' : 'Change'

      content_tag(:div, class: 'pull-right') if standalone

      html = button_to(
          button_text,
          register_contest_path(contest),
          method: :get,
          class: "btn #{btn_class}",
          form: {style: 'display: inline'},
      )
      if standalone
        content_tag(:div, class: 'pull-right') do
          html
        end
      else
        html
      end
    end
  end

  def contest_register_status(status, text)
    status_class = case
      when status.nil? then 'glyphicon glyphicon-remove text-danger'
      when status then 'glyphicon glyphicon-ok text-success'
      else 'glyphicon glyphicon-play text-warning'
    end
    status_class += ' align-middle' unless text
    show_text = case
      when !text then ''
      when status.nil? then "Not registered"
      when status then "Registered"
      else "Pending approval"
    end

    content_tag(:span, '', class: status_class) + ' ' + show_text
  end

  def contest_link(contest)
    is_running = contest.is_running? && contest.user_can_submit?(current_user)
    text = is_running ? 'Participate' : 'View'
    color = is_running ? 'btn-danger' : 'btn-primary'

    dest = contest.default_single_contest && !current_user&.admin? ? single_contest_path(contest) : contest
    link_to(text, dest, class: 'btn btn-xs ' + color, target: '_blank')
  end
end
