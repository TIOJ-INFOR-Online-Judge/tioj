# encoding: utf-8

class TestdataUploader < CarrierWave::Uploader::Base
  storage :file

  # Override the directory where uploaded files will be stored.
  def store_dir
    "#{Rails.root}/td/#{model.problem_id}"
  end

  def cache_dir
    "#{Rails.root}/td/cache"
  end

  def move_to_cache
    true
  end

  def move_to_store
    true
  end

  def filename
    original_filename.to_s + "-#{secure_token}" if original_filename.present?
  end

 protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
