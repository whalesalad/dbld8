class Location < ActiveRecord::Base
  attr_accessible :facebook_id, :lat, :lng, :name
end
