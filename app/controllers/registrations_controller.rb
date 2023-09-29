class RegistrationsController < Devise::RegistrationsController

  def new
    super
  end

  def edit
    super
  end

  def create
    if ENV["ALLOW_REGISTER"] == 'allow'
      super
      resource.remote_avatar_url = "http://avatar.3sd.me/100"
      resource.save
    elsif ENV["ALLOW_REGISTER"]&.start_with?('token_')
      if params[:register_token] != ENV["ALLOW_REGISTER"]
        redirect_to root_path, alert: 'Registration is not allowed!'
        return
      end
      super
      resource.remote_avatar_url = "http://avatar.3sd.me/100"
      resource.save
    else
      redirect_to root_path, alert: 'Registration is not allowed!'
    end
    # TODO: check resource.generate_random_avatar
  end

  def update
    super
  end

  def destroy
    redirect_to root_path, alert: "Please do not delete your account."
  end

end
