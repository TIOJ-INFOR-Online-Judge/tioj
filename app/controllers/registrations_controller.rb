class RegistrationsController < Devise::RegistrationsController

  def new
    super
  end

  def edit
    super
  end

  def create
    super
    # TODO: Implement https://github.com/mozillazg/random-avatar/blob/master/avatar/utils/visicon/__init__.py
    # to avoid 3rd party reliance
    resource.remote_avatar_url = "http://avatar.3sd.me/100"
    resource.save
  end

  def update
    super
  end

end
