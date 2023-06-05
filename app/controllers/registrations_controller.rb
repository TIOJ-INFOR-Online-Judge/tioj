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
      Visicon.new(SecureRandom.random_bytes(16), '', 128).draw_image.write(tmpfile.path)
      resource.avatar = tmpfile
      resource.save!
    end
  end

  def update
    super
  end

end
