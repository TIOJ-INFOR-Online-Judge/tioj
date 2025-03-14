# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  # Override the destroy action
  def destroy
    # Optionally, you could render a message or redirect instead
    redirect_to root_path, alert: "Account deletion is disabled."
  end
end

