# == Schema Information
#
# Table name: locations
#
#  id                  :integer         not null, primary key
#  name                :string(255)     not null
#  lat                 :decimal(15, 10)
#  lng                 :decimal(15, 10)
#  facebook_id         :integer(8)
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  locality            :string(255)
#  administrative_area :string(255)
#  country             :string(255)
#

class Location < ActiveRecord::Base
  attr_accessible :name, :latitude, :longitude, :facebook_id, 
    :locality, :admin_name, :admin_code, :country

  def as_json(options={})
    exclude = [:created_at, :updated_at]
    result = super({ :except => exclude }.merge(options))

    if country == 'US' && admin_code.present?
      if admin_code == 'DC'
        result[:name] = admin_name
      else
        result[:name] = "#{locality}, #{admin_code}"
      end
    end
    
    result
  end
end
