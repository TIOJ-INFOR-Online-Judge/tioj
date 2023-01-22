json.contest do
  json.extract! @contest, :contest_type
end
json.scores do
  json.array! @scores do |score|
    json.user do
      json.extract! score[0], :id, :username, :nickname
    end
    json.scores score[1..]
  end
end
