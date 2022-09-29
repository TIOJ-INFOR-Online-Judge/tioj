class MoveTestdataToNewTable < ActiveRecord::Migration[7.0]
  def up
    Problem.all.each do |problem|
      SampleTestdatum.create(problem_id: problem.id, input: problem.example_input, output: problem.example_output)
    end

    remove_column :problems, :example_input
    remove_column :problems, :example_output
  end
  def down
    add_column :problems, :example_input, :text, size: :medium
    add_column :problems, :example_output, :text, size: :medium

    SampleTestdatum.all.each do |t|
      problem = Problem.find(t.problem_id)
      if problem.example_input or problem.example_output
        next
      end
      problem.example_input = t.input
      problem.example_output = t.output
      problem.save
    end

    SampleTestdatum.delete_all
    execute("ALTER TABLE sample_testdata AUTO_INCREMENT=1")
  end
end
