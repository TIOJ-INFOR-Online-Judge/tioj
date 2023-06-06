class RegistrationsController < Devise::RegistrationsController

  def new
    super
  end

  def edit
    super
  end

  def create
    super
    resource.generate_random_avatar
    resource.save!
  end

  def update
    super
  end

end
