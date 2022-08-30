if current_user&.admin? or current_user&.id == @submission.user_id
  json.extract! @submission, :id, :code, :compiler, :result, :score, :created_at, :updated_at
else
  json.extract! @submission, :id, :compiler, :result, :score, :created_at, :updated_at
end
if @show_detail
  json.testdata_attributes @submission.submission_tasks do |task|
    json.extract! task, :position, :result, :time, :vss, :rss, :score
  end
end
