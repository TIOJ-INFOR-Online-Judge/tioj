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
    else
      redirect_to root_path, alert: 'Registration is not allowed!'
    end
  end

  def update
    super
  end

end
