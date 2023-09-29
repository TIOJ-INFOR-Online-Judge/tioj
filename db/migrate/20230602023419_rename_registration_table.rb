class RenameRegistrationTable < ActiveRecord::Migration[7.0]
  def change
    rename_table :contest_user_joints, :contest_registrations
  end
end
