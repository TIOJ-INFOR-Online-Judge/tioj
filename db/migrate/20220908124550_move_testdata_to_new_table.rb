class MoveTestdataToNewTable < ActiveRecord::Migration[7.0]
  def up
    data = Problem.all.map { |problem|
      input = problem.example_input
      output = problem.example_output
      split_re = /[\r\n]*^.*?(?:[Ss]ample|輸.*範(?:例|&#63925;)|範例測試).*?(?:$|<[^>]+>)[\r\n]*/
      inputs = input.split(split_re)
      outputs = output.split(split_re)
      if (input.empty? && output.empty?) || \
          (input.match(/沒有|無/) && output.match(/沒有|無/) && input.count("\n") == 0 && output.count("\n") == 0)
        []
      elsif inputs.size <= 1 or inputs.size != outputs.size
        {problem_id: problem.id, input: input, output: output}
      else
        inputs = inputs.drop(1)
        outputs = outputs.drop(1)
        inputs.zip(outputs).map {|x, y|
          {problem_id: problem.id, input: x, output: y}
        }
      end
    }.flatten
    SampleTestdatum.import(data)

    remove_column :problems, :example_input
    remove_column :problems, :example_output
  end
  def down
    add_column :problems, :example_input, :text, size: :medium
    add_column :problems, :example_output, :text, size: :medium

    data = SampleTestdatum.order(id: :asc).all.group_by(&:problem_id).values.map { |t|
      {
        id: t[0].problem_id,
        example_input: t[0].input,
        example_output: t[0].output,
        # dummy
        interlib_type: -1,
        specjudge_type: -1,
        verdict_ignore_td_list: -1,
      }
    }
    Problem.import(data, on_duplicate_key_update: [:example_input, :example_output], validate: false)
    SampleTestdatum.delete_all
  end
end
