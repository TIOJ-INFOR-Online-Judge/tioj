class MigrateUserWhitelist < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      direction.up do
        users = User.all.pluck(:id, :username)
        new_registrations = []
        Contest.where.not(user_whitelist: [nil, '']).update_all(register_mode: :require_approval)
        Contest.where.not(user_whitelist: [nil, '']).each do |contest|
          pat = Regexp.new(contest.user_whitelist, Regexp::IGNORECASE)
          new_registrations += users.filter{|x| pat.match(x[1])}.map{|x|
            {user_id: x[0], contest_id: contest.id, approved: true}
          }
        end
        ContestRegistration.import(new_registrations, on_duplicate_key_update: [:approved])
      end
      direction.down do
      end
    end
    remove_column :contests, :user_whitelist, :text
  end
end
