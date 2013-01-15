# encoding: UTF-8
# == Schema Information
#
# Table name: locations
#
#  id               :integer         not null, primary key
#  name             :string(255)     not null
#  locality         :string(255)
#  state            :string(255)
#  country          :string(255)
#  latitude         :float
#  longitude        :float
#  facebook_id      :integer(8)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  foursquare_id    :string(255)
#  venue            :string(255)
#  users_count      :integer         default(0)
#  address          :string(255)
#  geoname_id       :integer
#  activities_count :integer         default(0)
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
        :radius => '90000', 
        :limit => 100 
      }

      if query.nil?
        params[:section] = 'topPicks'
      else
        params[:query] = query
      end

      # Toggle this sucker between explore / search
      venues = Foursquare::Venue.explore(params)

      return venues.map { |v| v.location }
    end

    def find_cities_and_venues_near(latitude, longitude, query=nil)
      cities = find_cities_near(latitude, longitude)
      venues = find_venues_near(latitude, longitude, query)
      both = cities + venues
      return both.sort_by! { |l| l.distance }
    end
  end

  def to_s
    venue? ? venue : location_name
  end
  
  # Sets the internal name, not really used.
  def set_name
    self.name = self.to_s
  end

  def name
    to_s
  end

  def full_name
    "#{(venue?) ? "#{venue} • " : ''}#{location_name}"
  end

  def american?
    read_attribute(:country) == 'US'
  end

  def location_name
    # If we're Washington DC
    if state.present? && state.upcase == 'DC'
      return 'Washington, D.C.'
    end

    # If we're in the US
    if american?
      return "#{locality}, #{state}"
    end

    # International
    "#{locality}, #{country.name}"
  end

  def admin_name
    venue? ? venue : location_name
  end

  def country
    @country ||= Country.new(read_attribute(:country))
  end

  def short_country
    read_attribute :country
  end

  def has_point?
    latitude.present? && longitude.present?
  end

  def elasticsearch_point
    { lat: latitude, lon: longitude } if has_point?
  end

  def google_map_url
    "http://maps.google.com/maps?q=#{latitude},+#{longitude}" if has_point?
  end

  def type
    venue? ? 'venue' : 'city'
  end

  def city?
    foursquare_id.blank?
  end

  def venue?
    foursquare_id.present?
  end

  def foursquare_venue
    if venue?
      require 'foursquare'
      @foursquare_venue ||= Foursquare::Venue.find(foursquare_id, self)
    end
  end

  def foursquare_url
    "http://foursquare.com/v/#{foursquare_id}" if venue?
  end

  def as_json(options={})
    'BUILD'
  end

end
