class AddSpecjudgeReAsWaToProblems < ActiveRecord::Migration[7.2]
  def change
    add_column :problems, :judge_re_as_wa, :boolean, null: false, default: false
    reversible do |direction|
      direction.up do
        Problem.update_all(judge_re_as_wa: true)
      end
      direction.down do
      end
    end
  end
end
