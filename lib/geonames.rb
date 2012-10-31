require 'rest_client'
require 'json'

module Geonames
  API_SERVER = "http://api.geonames.org/"

  def self.default_params
    {
      :username => Rails.configuration.geonames_username,
      :radius => 60,
      :maxRows => 200
    }
  end

  def self.get(path, params=nil)
    full_path = API_SERVER + path
    
    params = (params.nil?) ? default_params : default_params.merge(params)

    response = RestClient.get full_path, { :params => params }

    JSON.parse(response)['geonames']
  end
  
  def self.places_near(latitude=nil, longitude=nil)
    response = self.get "findNearbyPlaceNameJSON", :lat => latitude, :lng => longitude

    # eliminate unpopulated areas
    response.reject! { |place| place['population'] < 10 }

    return response
  end

end