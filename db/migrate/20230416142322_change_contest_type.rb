class ChangeContestType < ActiveRecord::Migration[7.0]
  def change
    add_column :contests, :dashboard_during_contest, :boolean, default: true
    reversible do |direction|
      direction.up do
        Contest.where(contest_type: 1).update_all(contest_type: 0, dashboard_during_contest: false)
      end
      direction.down do
        Contest.where(contest_type: 0, dashboard_during_contest: false).update_all(contest_type: 1)
      end
    end
  end
end
