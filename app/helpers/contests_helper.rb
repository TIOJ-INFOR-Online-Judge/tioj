module ContestsHelper
  def contest_type_desc_map
    {
      "ioi" => "IOI style (rank by score)",
      "ioi_new" => "New IOI style (rank by score, union by subtasks)",
      "acm" => "ACM style (rank by solved problems)",
    }
  end

  def rel_timestamp(submission, start_time)
    submission.created_at_usec - to_us(start_time)
  end

  # return item_state
  def acm_ranklist_state(submission, start_time, item_state, is_waiting)
    # state: [attempts, ac_usec, is_first_ac, waiting]
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
        item_state[1] = rel_timestamp(submission, start_time)
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

  def ranklist_data(submissions, start_time, freeze_start, rule)
    res = Hash.new { |h, k| h[k] = [] }
    participants = Set[]
    func = rule == :acm ? method(:acm_ranklist_state) : method(:ioi_ranklist_state)
    first_ac = {}
    submissions.each do |sub|
      participants << sub.user_id
      next if ['CE', 'ER', 'CLE', 'JE'].include?(sub.result) && sub.created_at < freeze_start
      key = "#{sub.user_id}_#{sub.problem_id}"
      is_waiting = ['queued', 'received', 'Validating'].include?(sub.result) || sub.created_at >= freeze_start
      orig_state = res[key][-1]&.dig(:state)
      new_state = func.call(sub, start_time, orig_state, is_waiting)
      res[key] << {timestamp: rel_timestamp(sub, start_time), state: new_state} unless new_state.nil?
      first_ac[sub.problem_id] = first_ac.fetch(sub.problem_id, sub.user_id) if sub.result == 'AC'
    end
    res.delete_if { |key, value| value.empty? }
    {result: res, participants: participants.to_a, first_ac: first_ac}
  end
end
