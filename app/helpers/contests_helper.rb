module ContestsHelper
  def contest_type_desc_map
    {
      "gcj" => "gcj style (partial/dashboard)",
      "ioi" => "ioi style (partial/no dashboard)",
      "acm" => "acm style (no partial/dashboard)",
    }
  end

  def rel_timestamp(submission, start_time)
    submission.created_at_usec - (start_time.to_i * 1000000 + start_time.usec)
  end

  # return item_state; global_state will be changed
  def acm_ranklist_state(submission, start_time, item_state, global_state)
    # state: [attempts, ac_usec, is_first_ac]
    if item_state.nil?
      item_state = [0, nil, nil]
    end
    return nil if not item_state[1].nil? or ['CE', 'ER', 'CLE', 'JE'].include?(submission.result)
    item_state = item_state.dup
    item_state[0] += 1
    if submission.result == 'AC'
      item_state[1] = rel_timestamp(submission, start_time)
      item_state[2] = !global_state[submission.problem_id]
      global_state[submission.problem_id] = true
    end
    item_state
  end

  def ioi_ranklist_state(submission, start_time, item_state, global_state)
    # state: score
    if item_state.nil?
      item_state = BigDecimal('-1e+12')
    end
    item_state >= submission.score ? nil : submission.score
  end

  def ranklist_data(submissions, start_time, freeze_start, rule)
    res = Hash.new { |h, k| h[k] = [] }
    waiting = Hash.new(0)
    participants = Set[]
    global_state = {}
    func = rule == :acm ? method(:acm_ranklist_state) : method(:ioi_ranklist_state)
    submissions.each do |sub|
      key = "#{sub.user_id}_#{sub.problem_id}"
      if ['queued', 'received', 'Validating'].include?(sub.result) or sub.created_at >= freeze_start
        waiting[key] += 1
        next
      end
      orig_state = res[key][-1]&.dig(:state)
      new_state = func.call(sub, start_time, orig_state, global_state)
      res[key] << {timestamp: rel_timestamp(sub, start_time), state: new_state} unless new_state.nil?
      participants << sub.user_id
    end
    res.delete_if { |key, value| value.empty? }
    {result: res, waiting: waiting, participants: participants.to_a}
  end
end
