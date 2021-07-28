if user_signed_in? && current_user.admin == true
  json.array!(@submissions) do |submission|
    json.extract! submission, :id, :code, :compiler, :result, :score
    json.url submission_url(submission, format: :json)
  end
end
