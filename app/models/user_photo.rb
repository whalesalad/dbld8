# == Schema Information
#
# Table name: user_photos
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  image      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class UserPhoto < ActiveRecord::Base
  attr_accessible :image
  
  belongs_to :user

  validates_presence_of :image, :user_id

  default_scope order("created_at DESC")

  class UserPhotoUploader < CarrierWave::Uploader::Base
    # Include RMagick or MiniMagick support:
    include CarrierWave::RMagick
    include CarrierWave::MimeTypes
    # include CarrierWave::MiniMagick

    # User S3 for file storage
    storage :fog

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      # user/userid/photos/photoid/file
      "user/#{model.user_id}/photos/#{model.id}"
    end

    def filename 
      if original_filename 
        @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
        "#{@name}.#{file.extension}"
      end
    end

    process :set_content_type

    version :thumb do
      process :resize_to_fill => [200, 200]
    end

    version :small do
      process :resize_to_fill => [320, 200]
    end

    version :medium do
      process :resize_to_fill => [640, 400]
    end

    version :large do
      process :resize_to_limit => [960, 640]
    end

    def extension_white_list
      %w(jpg jpeg gif png)
    end

  end

  mount_uploader :image, UserPhotoUploader

  def thumb
    image.thumb
  end

  def large
    image.large
  end

  def as_json(options={})
    result = super({ :only => [:id] })
    result[:thumb] = image.thumb.url
    result[:large] = image.large.url
    result
  end
  
end
