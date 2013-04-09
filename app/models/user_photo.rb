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
  attr_accessible :image, :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  
  belongs_to :user, :touch => true
  validates_presence_of :image, :user

  after_update :crop_image

  default_scope order("created_at DESC")

  def self.recreate_images!
    self.all.each { |photo| photo.image.recreate_versions! }
  end

  class UserPhotoUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
    include CarrierWave::MimeTypes

    storage :fog

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
      return "http://static-test.dbld8.com/#{self.current_path}" if Rails.env.development?
      "http://asset-#{rand(3)+1}.dbld8.com/#{self.current_path}"
    end

    def crop_and_resize_to_fill(width, height, gravity = 'Center')
      image = MiniMagick::Image.read(read)

      if model.should_crop?
        crop_width = model.crop_w.to_i
        crop_height = model.crop_h.to_i
        crop_x = model.crop_x.to_i
        crop_y = model.crop_y.to_i
        image.crop "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}"
      end

      # This is borrowed from CarrierWave's internal source.
      # carrierwave.rubyforge.org/rdoc/classes/CarrierWave/MiniMagick.html
      cols, rows = image[:dimensions]
      image.combine_options do |cmd|
        if width != cols || height != rows
          scale_x = width/cols.to_f
          scale_y = height/rows.to_f
          if scale_x >= scale_y
            cols = (scale_x * (cols + 0.5)).round
            rows = (scale_x * (rows + 0.5)).round
            cmd.resize "#{cols}"
          else
            cols = (scale_y * (cols + 0.5)).round
            rows = (scale_y * (rows + 0.5)).round
            cmd.resize "x#{rows}"
          end
        end
        cmd.gravity gravity
        cmd.background "rgba(0,235,255,0.0)"
        cmd.extent "#{width}x#{height}" if cols != width || rows != height
      end

      image.write(current_path)
    end

    process :set_content_type

    version :thumb do
      process :resize_to_fill => [200, 200]
    end

    version :small do
      process :crop_and_resize_to_fill => [320, 200, 'North']
    end

    version :medium do
      process :crop_and_resize_to_fill => [640, 400, 'North']
    end

    def extension_white_list
      %w(jpg jpeg gif png)
    end
  end

  mount_uploader :image, UserPhotoUploader

  def should_crop?
    crop_x.present? && crop_y.present?
  end

  def crop_image
    image.recreate_versions! if should_crop?
  end

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
