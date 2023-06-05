class RegistrationsController < Devise::RegistrationsController

  def new
    super
  end

  def edit
    super
  end

  def create
    super
    Tempfile.create(['', '.png']) do |tmpfile|
      Visicon.new(SecureRandom.random_bytes(16), '', 64).draw_image.write(tmpfile.path)
      resource.avatar = tmpfile
      logger.fatal tmpfile
      resource.save!
    end
  end

  def update
    super
  end

end
