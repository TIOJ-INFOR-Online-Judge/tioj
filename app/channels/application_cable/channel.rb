module ApplicationCable
  class Channel < ActionCable::Channel::Base
    protected

    def calc_td_set_scores(submission)
      score_map = submission.submission_tasks.map { |t| [t.position, t.score] }.to_h
      problem = submission.problem
      num_tasks = problem.testdata.count
      problem.testdata_sets.order(id: :asc).map.with_index{|s, index|
        lst = ApplicationController.td_list_to_arr(s.td_list, num_tasks)
        set_result = score_map.values_at(*lst)
        finished = set_result.all?
        set_score = finished ? (((lst.size > 0 ? set_result.min : BigDecimal(100)) * s.score) / 100).round(problem.score_precision) : 0
        {score: set_score, ratio: set_score.to_f / s.score.to_f, position: index, finished: finished}
      }
    end
  end
end
