class AddTeamToContestRegistration < ActiveRecord::Migration[7.0]
  def change
    add_reference :contest_registrations, :team, foreign_key: true
  end
end
