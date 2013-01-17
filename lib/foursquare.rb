$LOAD_PATH << File.dirname(__FILE__)

require 'rest_client'
require 'json'
require "foursquare/venue"
require "foursquare/category"

module Foursquare
  API_SERVER = "https://api.foursquare.com/v2"

  def self.default_params
    {
      :client_id => Rails.configuration.foursquare_client_id,
      :client_secret => Rails.configuration.foursquare_client_secret,
      :v => current_version
    }
  end

  def self.current_version
    Time.now.strftime '%Y%m%d'
  end

  def self.get(path, params=nil)
    full_path = API_SERVER + path

    params = (params.nil?) ? default_params : default_params.merge(params)

    response = RestClient.get full_path, { :params => params }

    # debug 'Full Path', full_path
    # debug 'Params', params
    # debug 'Response', response

    JSON.parse(response)['response']
  end

  def self.debug(label, data)
    puts "=== [FOURSQUARE] #{label.upcase} ==="
    puts data
    puts "\n"    
  end
end