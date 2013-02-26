require 'rest_client'
require 'json'

module Geonames
  API_SERVER = "http://api.geonames.org/"

  def self.default_params
    {
      :username => Rails.configuration.geonames_username,
      :radius => 100,
      :maxRows => 200
    }
  end

  def self.get(path, params=nil)
    full_path = API_SERVER + path
    
    params = (params.nil?) ? default_params : default_params.merge(params)

    response = RestClient.get full_path, { :params => params }

    JSON.parse(response)['geonames']
  end
  
  def self.cities_near(latitude=nil, longitude=nil)
    response = self.get "findNearbyPlaceNameJSON", :lat => latitude, :lng => longitude

    # eliminate unpopulated areas
    response.reject! { |city| city['population'] < 1000 }

    results = response.map do |raw_location|
      self.location_from_geonames(raw_location)
    end

    return results
  end

  def self.first_for(latitude=nil, longitude=nil)
    self.cities_near(latitude, longitude).sort_by { 'population' }.first
  end

  def self.location_from_geonames(geonames_data)
    params = {
      :geoname_id => geonames_data['geonameId'],
      :country => geonames_data['countryCode'], 
      :state => geonames_data['adminCode1'],
      :locality => geonames_data['toponymName'],
      :latitude => geonames_data['lat'],
      :longitude => geonames_data['lng']
    }

    location = Location.find_or_create_by_geoname_id(params)
    
    location.distance = geonames_data['distance'].to_i * 1000

    return location
  end

end