json.array!(@submissions) do |submission|
  if user_signed_in? && current_user.admin == true
    json.extract! submission, :id, :code, :compiler, :result, :score
  else
    json.extract! submission, :id, :compiler, :result, :score
  end
  json.url submission_url(submission, format: :json)
end
