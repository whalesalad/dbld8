# == Schema Information
#
# Table name: users
#
#  id                    :integer         not null, primary key
#  email                 :string(255)
#  password_digest       :string(255)
#  facebook_id           :integer(8)
#  facebook_access_token :string(255)
#  first_name            :string(255)
#  last_name             :string(255)
#  birthday              :date
#  single                :boolean         default(TRUE)
#  interested_in         :string(255)
#  gender                :string(255)
#  bio                   :text
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  location_id           :integer
#  uuid                  :uuid            not null
#  invite_slug           :string(255)
#  type                  :string(255)
#

class EmailUser < User
  validates_uniqueness_of :email, 
    :message => "A user already exists with this email address."
  
  validates_presence_of :password, :email, :on => :create

  def default_thumb
    "https://db00q50qzosdc.cloudfront.net/misc/no-photo-thumb-#{gender}.png"
  end

  def default_photo
    "https://db00q50qzosdc.cloudfront.net/misc/no-photo-#{gender}.png"
  end
end
