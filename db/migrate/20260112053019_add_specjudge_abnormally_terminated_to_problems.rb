class AddSpecjudgeAbnormallyTerminatedToProblems < ActiveRecord::Migration[7.2]
  def change
    add_column :problems, :judge_abnormally_terminated, :boolean, null: false, default: false
    reversible do |direction|
      direction.up do
        Problem.where(specjudge_type: :new).update_all(judge_abnormally_terminated: true)
      end
      direction.down do
      end
    end
  end
end
