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

class Location < ActiveRecord::Base
  after_initialize :set_name

  attr_accessor :distance

  attr_accessible :name, :latitude, :longitude, :facebook_id,
    :locality, :admin_name, :admin_code, :country, :foursquare_id,
    :place

  has_many :users, :dependent => :nullify
  has_many :activities

  # Class Methods
  class << self
    def find_cities_near_point(latitude, longitude)
      require 'geonames'

      results = Array.new

      places = Geonames.places_near(latitude, longitude)

      places.each do |raw_location|
        location = Location.find_or_create_by_name(:country => raw_location['countryCode'], 
                                                   :admin_name => raw_location['adminName1'],
                                                   :admin_code => raw_location['adminCode1'],
                                                   :locality => raw_location['toponymName'],
                                                   :latitude => raw_location['lat'],
                                                   :longitude => raw_location['lng'])
        
        # temporarily store distance for this result set. 
        location.distance = raw_location['distance']

        results.push location
      end

      results.sort_by! { |l| l.distance.to_i }
    end

    def find_places_near_point(latitude, longitude)
      require 'foursquare'

      venues = Foursquare::Venue.explore :ll => "#{latitude},#{longitude}"

      locations = venues.map do |venue|
        venue.location_and_save!
      end
    end
  end
  
  def to_s
    if place.present?
      "#{place} - #{location_name}"
    else
      location_name  
    end
  end

  def location_name
    return admin_name if admin_code.present? && admin_code == 'DC'

    return "#{locality}, #{admin_code}" if read_attribute(:country) == 'US'

    "#{locality}, #{country.name}"
  end

  def admin_name
    if place.present?
      place
    else
      location_name  
    end
  end

  def set_name
    self.name ||= self.to_s
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
