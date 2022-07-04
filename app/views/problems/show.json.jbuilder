json.extract! @problem, :id, :name, :description, :input, :output, :example_input, :example_output, :hint, :source, :created_at, :updated_at
json.limit_attributes do
json.extract! @problem.limit, :time, :vss, :rss, :output
end

