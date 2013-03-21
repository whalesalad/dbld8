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
#  foursquare_icon  :string(255)
#  population       :integer(8)
#

class Location < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessor :distance

  attr_accessible :latitude, :longitude, :facebook_id,
    :locality, :state, :country, :foursquare_id, :foursquare_icon,
    :venue, :address, :geoname_id, :population

  has_many :users, :dependent => :nullify
  has_many :activities

  scope :cities, where(:foursquare_id => nil)
  scope :venues, where('foursquare_id IS NOT NULL')

  validates_uniqueness_of :geoname_id, :allow_nil => :true
  validates_uniqueness_of :foursquare_id, :allow_nil => :true

  def self.tire_settings
    {
      analysis: {
        analyzer: {
          ascii_analyzer: {
            "tokenizer" => "lowercase",
            "filter" => ["asciifolding", "stop"],
            "type" => "custom"
          }
        }
      }
    }
  end

  settings self.tire_settings do
    mapping do
      indexes :id, :index => :not_analyzed
      indexes :name, :type => 'string', :analyzer => 'ascii_analyzer', :as => 'name', :boost => 100
      indexes :point, :type => 'geo_point', :as => 'elasticsearch_point'
      indexes :venue, :analyzer => 'snowball'
      indexes :address, :analyzer => 'snowball'
      indexes :locality, :analyzer => 'snowball'
      indexes :country, :analyzer => 'snowball', :as => 'short_country'
      indexes :kind, :analyzer => 'keyword', :as => 'type'
    end
  end

  def self.search(params={})
    Rails.logger.debug("[TIRE SEARCH] #{self.model_name.human}: #{params.inspect}")

    tire.search(:per_page => 30, :load => true) do
      # Sort the results by proximity to point
      sort { by '_geo_distance' => { point: params[:point] }} if params[:point].present?

      # Query for name/address
      if params[:query].present?
        query { match [:name, :address], params[:query], type: 'phrase_prefix' }
      end

      # Only display those of a certain kind/type
      filter(:term, :kind => params[:kind]) if params[:kind].present?
    end
  end

  def self.find_cities_near(latitude, longitude)
    self.search({ :point => "#{latitude},#{longitude}" })
  end

  def self.find_venues_near(point, query=nil)
    params = { 
      :ll => point,
      :radius => '90000',
      :limit => 100
    }
    
    # params[:section] = 'topPicks'
    if query.present?
      params[:query] = query
    end

    # Toggle this sucker between explore / search
    venues = Foursquare::Venue.explore(params)

    venues.map { |v| v.location }
  end

  def self.get_foursquare_icons
    self.venues.where(:foursquare_icon => nil).each do |location|
      location.foursquare_icon = location.foursquare_venue.icon
      location.save!
    end
  end

  def to_s
    name
  end
  
  def name
    venue? ? venue : location_name
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
    unless locality.present?
      return country.name
    end
    
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

  def str_point
    "#{latitude},#{longitude}"
  end

  def elasticsearch_point
    { lat: latitude, lon: longitude } if has_point?
  end

  def google_map_url
    "http://maps.google.com/maps?q=#{str_point}" if has_point?
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
    return false unless venue?
    @foursquare_venue ||= Foursquare::Venue.find(foursquare_id, self)
  end

  def foursquare_url
    "http://foursquare.com/v/#{foursquare_id}" if venue?
  end

  def has_icon?
    !foursquare_icon.nil?
  end

  def icon(size=256, transparent=false)
    return nil unless has_icon?

    sizes = [32, 64, 88, 256]
    size = 256 unless sizes.include?(size)
    foursquare_icon % "#{(transparent) ? '' : 'bg_'}#{size}"
  end

end
