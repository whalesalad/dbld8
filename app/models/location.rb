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
    :locality, :state, :country, :foursquare_id,
    :venue, :address, :geoname_id

  has_many :users, :dependent => :nullify
  has_many :activities

  scope :cities, where(:foursquare_id => nil)
  scope :venues, where('foursquare_id IS NOT NULL')

  validates_uniqueness_of :geoname_id, :allow_nil => :true
  validates_uniqueness_of :foursquare_id, :allow_nil => :true

  # Class Methods
  class << self
    def find_cities_near(latitude, longitude)
      require 'geonames'

      results = Array.new

      cities = Geonames.cities_near(latitude, longitude)

      cities.each do |raw_location|
        params = {
          :geoname_id => raw_location['geonameId'],
          :country => raw_location['countryCode'], 
          :state => raw_location['adminCode1'],
          :locality => raw_location['toponymName'],
          :latitude => raw_location['lat'],
          :longitude => raw_location['lng']
        }

        location = Location.find_or_create_by_geoname_id(params)
        
        # temporarily store distance for this result set. 
        location.distance = raw_location['distance'].to_i * 1000

        results.push location
      end

      results.sort_by! { |l| l.distance.to_i }
    end

    def find_venues_near(latitude, longitude, query=nil)
      require 'foursquare'

      params = { 
        :ll => "#{latitude},#{longitude}", 
        :intent => 'checkin', 
        :radius => '5000', 
        :limit => 100 
      }

      unless query.nil?
        params[:query] = query
      end

      # Toggle this sucker between explore / search
      venues = Foursquare::Venue.explore params

      return venues.map do |venue|
        venue.location
      end
    end

    def find_cities_and_venues_near(latitude, longitude, query=nil)
      cities = find_cities_near(latitude, longitude)
      venues = find_venues_near(latitude, longitude, query)
      both = cities + venues
      return both.sort_by! { |l| l.distance }
    end
  end
  
  def set_name
    self.name ||= self.to_s
  end

  def to_s
    prefix = (venue.present?) ? "#{venue} - " : ''
    "#{prefix}#{location_name}"  
  end

  def location_name
    # If we're Washington DC
    if state.present? && state.upcase == 'DC'
      return 'Washington, D.C.'
    end

    # If we're in the US
    if read_attribute(:country) == 'US'
      return "#{locality}, #{state}"
    end

    # International
    "#{locality}, #{country.name}"
  end

  def admin_name
    (venue.present?) ? venue : location_name
  end

  def country
    @country ||= Country.new(read_attribute(:country))
  end

  def google_map_url
    if latitude.present? and longitude.present?
      "http://maps.google.com/maps?q=#{latitude},+#{longitude}"
    end
  end

  def city?
    foursquare_id.blank?
  end

  def foursquare?
    foursquare_id.present?
  end

  def foursquare_venue
    if foursquare?
      require 'foursquare'
      @foursquare_venue ||= Foursquare::Venue.find(foursquare_id, self)
    end
  end

  def foursquare_url
    if foursquare?
      "http://foursquare.com/v/#{foursquare_id}"
    end
  end

  def as_json(options={})
    exclude = [:created_at, :updated_at, :facebook_id, :country]

    if options[:short]
      exclude += [:latitude, :longitude, :users_count, :state, :locality]
    end
    
    result = super({ :except => exclude }.merge(options))

    result[:country] = read_attribute(:country)

    if distance.present?
      result[:distance] = distance
    end
    
    result
  end

end
