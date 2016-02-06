# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file
  # storage :fog  // TODO

  process resize_to_fill: [164, 164]

  version :small do
    process resize_to_fill: [48, 48]
  end

  def default_url
    ActionController::Base.helpers.asset_path('' + [version_name, 'avatar.png'].compact.join('_'))
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
