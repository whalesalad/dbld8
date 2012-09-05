# == Schema Information
#
# Table name: locations
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  lat         :decimal(15, 10)
#  lng         :decimal(15, 10)
#  facebook_id :integer(8)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Location < ActiveRecord::Base
  attr_accessible :facebook_id, :lat, :lng, :name
end
