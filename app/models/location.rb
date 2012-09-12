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
  attr_accessible :name, :lat, :lng, :facebook_id, 
    :locality, :administrative_area, :country

  def as_json(options={})
    exclude = [:created_at, :updated_at]
    result = super({ :except => exclude }.merge(options))
    
    result
  end
end
