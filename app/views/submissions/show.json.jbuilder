if effective_admin? or current_user&.id == @submission.user_id
  json.extract! @submission, :id, :problem_id, :compiler, :result, :score, :created_at, :updated_at #, :code
else
  json.extract! @submission, :id, :problem_id, :compiler, :result, :score, :created_at, :updated_at
end

if @show_detail
  json.testdata_attributes @submission.submission_testdata_results do |task|
    json.extract! task, :position, :result, :time, :vss, :rss, :score
  end
  json.subtask_result @submission.get_subtask_result
end
