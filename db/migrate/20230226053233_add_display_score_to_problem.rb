class AddDisplayScoreToProblem < ActiveRecord::Migration[7.0]
  def change
    add_column :problems, :ranklist_display_score, :boolean, default: false
    Problem.where(specjudge_type: :new).update_all(ranklist_display_score: true)
    Problem.where.not(verdict_ignore_td_list: '').update_all(ranklist_display_score: true)
  end
end
