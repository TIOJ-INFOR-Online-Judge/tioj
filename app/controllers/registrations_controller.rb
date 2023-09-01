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
    resource.save # errors would have already happened and rendered in super
  end

  def update
    super
  end

end
