class FetchChannel < ApplicationCable::Channel
  def subscribed
    stream_from "fetch_#{judge_server.id}"
    stream_from 'fetch'
  end

  def td_result(data)
    data = data.deep_symbolize_keys
    submission = Submission.find(data[:submission_id])
    update_task_results(data[:results], submission)
  end

  def submission_result(data)
    data = data.deep_symbolize_keys
    submission = Submission.find(data[:submission_id])
    if ['Validating', 'queued'].include? data[:verdict]
      submission.update(:result => data[:verdict])
      ActionCable.server.broadcast("submission_#{submission.id}_overall", {id: submission.id, result: data[:verdict]})
      return
    end
    update_task_results(data[:td_results], submission) if data[:td_results]
    update_hash = {}
    if data[:message]
      update_hash[:message] = data[:message]
    end
    v2i = ApplicationController.v2i
    update_hash[:result] = ApplicationController.i2v[v2i.fetch(data[:verdict], v2i['JE'])]
    if ['JE', 'ER', 'CE', 'CLE'].include? update_hash[:result]
      update_hash[:score] = 0
      update_hash[:total_time] = 0
      update_hash[:total_memory] = 0
    else
      tasks = submission.submission_tasks
      update_hash[:total_time] = tasks.map{|i| i.time}.sum.round(0)
      update_hash[:total_memory] = tasks.map{|i| i.rss}.max || 0
    end
    retry_op do |is_first|
      submission.reload if not is_first
      submission.with_lock do
        submission.update(**update_hash)
      end
    end
    ActionCable.server.broadcast("submission_#{submission.id}_overall", update_hash.merge({id: submission.id}))
  end

  def report_queued(data)
    data = data.deep_symbolize_keys
    # judge client will report every 10 seconds if has submission queued; 30 seconds otherwise
    Submission.where(id: data[:submission_ids]).update_all(updated_at: Time.now)
    # requeue dead submissions
    retry_op do |is_first|
      Submission.where(result: ["received", "Validating"], updated_at: ..40.second.ago).update_all(result: "queued")
    end
  end

  def fetch_submission(data)
    n_retry = 5
    for i in 1..n_retry
      submission = Submission.where(result: "queued").order(Arel.sql('contest_id IS NOT NULL ASC'), id: :asc).first
      flag = false
      if submission
        retry_op(3) do |is_first|
          submission.reload if not is_first
          submission.with_lock do
            if submission.result == "received"
              if i != n_retry
                flag = true
                next # breaks with_lock
              end
              return
            end
            submission.update(result: "received")
          end
          next if flag
        end
        next if flag
      else
        return
      end
      break
    end
    problem = submission.problem
    user = submission.user
    td_count = problem.testdata.count
    verdict_ignore_set = TestdataSet.td_list_str_to_arr(problem.verdict_ignore_td_list, td_count)
    priority = (submission.contest ? 100000000 : 0) - submission.id
    data = {
      submission_id: submission.id,
      contest_id: submission.contest_id || -1,
      priority: priority,
      compiler: submission.compiler.name,
      time: submission.created_at.to_i * 1000000 + submission.created_at.usec,
      code: submission.code.to_s,
      skip_group: problem.skip_group || submission.contest&.skip_group || false,
      user: {
        id: user.id,
        name: user.username,
        nickname: user.nickname,
      },
      problem: {
        id: problem.id,
        specjudge_type: Problem.specjudge_types[problem.specjudge_type],
        specjudge_compiler: problem.specjudge_compiler&.name,
        interlib_type: Problem.interlib_types[problem.interlib_type],
        sjcode: problem.sjcode || "",
        interlib: problem.interlib || "",
        interlib_impl: problem.interlib_impl || "",
        strict_mode: problem.strict_mode,
        num_stages: problem.num_stages,
        judge_between_stages: problem.judge_between_stages,
        default_scoring_args: ApplicationController.shellsplit_safe(problem.default_scoring_args),
      },
      td: problem.testdata.map.with_index { |t, index|
        {
          id: t.id,
          updated_at: t.updated_at.to_i * 1000000 + t.updated_at.usec,
          time: t.time_limit * 1000, # us
          vss: t.vss_limit || 0,
          rss: t.rss_limit || 0,
          input_compressed: t.input_compressed,
          output_compressed: t.output_compressed,
          output: t.output_limit,
          verdict_ignore: verdict_ignore_set.include?(index),
        }
      },
      tasks: problem.testdata_sets.map { |s|
        {
          positions: s.td_list_arr(td_count),
          score: (s.score * BigDecimal('1e+6')).to_i,
        }
      },
    }
    ActionCable.server.broadcast("fetch_#{judge_server.id}", {type: 'submission', data: data})
    ActionCable.server.broadcast("submission_#{submission.id}_overall", {result: 'received', id: submission.id})
  end

  def unsubscribed
  end

  private

  def update_task_results(data, submission)
    results = data.map { |res|
      {
        submission_id: submission.id,
        position: res[:position],
        result: res[:verdict],
        time: BigDecimal(res[:time]) / 1000,
        rss: res[:rss],
        vss: res[:vss],
        score: (BigDecimal(res[:score]) / BigDecimal('1e+6')).round(6).clamp(BigDecimal('-1e+6'), BigDecimal('1e+6')),
        message_type: res[:message_type],
        message: res[:message],
      }
    }
    SubmissionTask.import(results, on_duplicate_key_update: [:result, :time, :vss, :rss, :score, :message_type, :message])
    td_set_scores = submission.calc_td_set_scores
    score = td_set_scores.sum{|x| x[:score]}
    max_score = BigDecimal('1e+12') - 1
    score = score.clamp(-max_score, max_score).round(6)
    retry_op do |is_first|
      submission.reload if not is_first
      submission.with_lock do
        return if not ['Validating', 'received'].include?(submission.result)
        submission.update(:score => score)
      end
    end
    ActionCable.server.broadcast("submission_#{submission.id}", {td_set_scores: td_set_scores, tasks: results})
    ActionCable.server.broadcast("submission_#{submission.id}_overall", {score: score, result: submission.result, id: submission.id})
  end

  def retry_op(retry_times=4, interval=0.3)
    is_first = true
    begin
      raise ActiveRecord::Deadlocked if retry_times == 4
      yield(is_first)
    rescue ActiveRecord::Deadlocked => e
      retry_times -= 1
      is_first = false
      if retry_times > 0
        sleep interval
        retry
      else
        raise e
      end
    end
  end
end
