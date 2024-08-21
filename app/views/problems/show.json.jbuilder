json.extract! @problem, :id, :name, :description, :input, :output, :hint, :source, :subtasks
# json.sample_testdata @problem.sample_testdata

json.testdata do
  json.array!(@problem.testdata) do |td|
    json.extract! td, :id, :position, :time_limit, :vss_limit, :rss_limit, :output_limit
  end
end
