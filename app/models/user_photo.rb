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
  
  belongs_to :user, :touch => true

  validates_presence_of :image, :user_id

  default_scope order("created_at DESC")

  def self.recreate_images!
    self.all.each { |photo| photo.image.recreate_versions! }
  end

  class UserPhotoUploader < CarrierWave::Uploader::Base
    # include CarrierWave::RMagick
    include CarrierWave::MiniMagick
    include CarrierWave::MimeTypes

    # User S3 for file storage
    storage :fog

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "user/#{model.user.uuid}/photos"
    end

    def filename 
      if original_filename 
        @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
        "#{@name}.#{file.extension}"
      end
    end

    def url
      # if Rails.env.development?
      #   return "http://static-test.dbld8.com/" + self.current_path
      # end

      "http://asset-#{rand(3) + 1}.dbld8.com/" + self.current_path
      # "https://db00q50qzosdc.cloudfront.net/" + self.current_path
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

    def extension_white_list
      %w(jpg jpeg gif png)
    end

  end

  mount_uploader :image, UserPhotoUploader

  def thumb
    image.thumb
  end

  def small
    image.small
  end

  def medium
    image.medium
  end

  # KISS KISS
  def as_json(options={})
    {
      id: id,
      thumb: image.thumb.url,
      small: image.small.url,
      medium: image.medium.url,
      original: image.url
    }
  end
  
end
