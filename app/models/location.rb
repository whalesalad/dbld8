# == Schema Information
#
# Table name: locations
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  locality    :string(255)
#  admin_name  :string(255)
#  admin_code  :string(255)
#  country     :string(255)
#  latitude    :float
#  longitude   :float
#  facebook_id :integer(8)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  users_count :integer         default(0)
#

require 'rest_client'
require 'json'

class Location < ActiveRecord::Base
  attr_accessor :distance

  attr_accessible :name, :latitude, :longitude, :facebook_id,
    :locality, :admin_name, :admin_code, :country, :foursquare_id,
    :place

  has_many :users, :dependent => :nullify
  has_many :activities

  # Class Methods
  class << self
    def raw_geonames_places_near(latitude, longitude)
      geonames_url = "http://api.geonames.org/findNearbyPlaceNameJSON"

      geonames_data = RestClient.get geonames_url, { :params => {
        :lat => latitude,
        :lng => longitude,
        :radius => 60,
        :maxRows => 200,
        :username => 'whalesalad'
      }}

      JSON.parse(geonames_data.body)['geonames']
    end

    def find_near_point(latitude, longitude)
      results = Array.new

      raw_locations = raw_geonames_places_near(latitude, longitude)

      raw_locations.each do |raw_location|
        if raw_location['population'] > 10
          location_name = "#{raw_location['toponymName']}, #{raw_location['adminName1']}"

          location = Location.find_or_create_by_name(:name => location_name,
                                                     :country => raw_location['countryCode'], 
                                                     :admin_name => raw_location['adminName1'],
                                                     :admin_code => raw_location['adminCode1'],
                                                     :locality => raw_location['toponymName'],
                                                     :latitude => raw_location['lat'],
                                                     :longitude => raw_location['lng'])
          
          # Temporarily store distance for this result set. 
          # We should be doing this ourselves but whateva
          location.distance = raw_location['distance']

          results.push location
        end
      end

      # Sort (by distance) and return the results
      results.sort_by! { |l| l.distance.to_i }
    end
  end
  
  def to_s
    name
  end

  def name
    if read_attribute(:country) == 'US' && admin_code.present?
      return (admin_code == 'DC') ? admin_name : "#{locality}, #{admin_code}"
    end

    "#{locality}, #{country.name}"
  end

  def country
    @country ||= Country.new(read_attribute(:country))
  end

  def google_map_url
    if latitude.present? and longitude.present?
      "http://maps.google.com/maps?q=#{latitude},+#{longitude}"
    end
  end

  def foursquare_venue
    unless foursquare_id.empty?
      require 'foursquare'
      @foursquare_venue ||= Foursquare::Venue.find(foursquare_id, self)
    end
  end

  def as_json(options={})
    exclude = [:created_at, :updated_at, :facebook_id, :country]

    if options[:short]
      exclude += [:latitude, :longitude, :locaity, :users_count, :admin_code, :admin_name, :locality]
    end
    
    result = super({ :except => exclude }.merge(options))

    result[:country] = read_attribute(:country)

    if distance.present?
      result[:distance] = distance
    end
    
    result
  end

end
