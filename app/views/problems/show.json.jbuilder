json.extract! @problem, :id, :name, :description, :input, :output, :example_input, :example_output, :hint, :source, :testdata_sets
json.testdata do
  json.array!(@problem.testdata) do |td|
    json.extract! td, :id, :position, :time_limit, :vss_limit, :rss_limit, :output_limit
  end
end
