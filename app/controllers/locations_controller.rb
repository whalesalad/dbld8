require 'rest_client'
require 'json'

class LocationsController < ApplicationController
  skip_before_filter :require_token_auth, :only => [:index, :show, :search]
  
  respond_to :json

  def index
    @locations = Location.all

    respond_with @locations
  end

  def search
    @locations = []
    if params[:latitude] and params[:longitude]
      # we're doing a geo query!!!
      
      # Using Geonames...
      geonames_data = RestClient.get 'http://api.geonames.org/findNearbyPlaceNameJSON', { :params => {
        :lat => params[:latitude],
        :lng => params[:longitude],
        :radius => 60,
        :maxRows => 200,
        :username => 'whalesalad'
      }}

      parsed = JSON.parse(geonames_data.body)['geonames']

      parsed.each do |location|
        if location['population'] > 10
          _loc_name = "#{location['toponymName']}, #{location['adminName1']}"

          _loc = Location.find_or_create_by_name(:name => _loc_name,
                                                 :country => location['countryCode'], 
                                                 :admin_name => location['adminName1'],
                                                 :admin_code => location['adminCode1'],
                                                 :locality => location['toponymName'],
                                                 :latitude => location['lat'],
                                                 :longitude => location['lng'])
          
          # Store distance. We should be doing this ourselves but whateva
          _loc[:distance] = location['distance']

          @locations.push _loc
        end
      end

      @locations.sort_by! { |l| l[:distance].to_i }
    end

    respond_with @locations and return
  end

  def show
    @location = Location.find(params[:id])
    respond_with @location
  end

  # POST
  def create
    @interest = Interest.new(params[:interest])

    if @interest.save
      respond_with(@interest, status: :created, location: @interest)
    else
      respond_with(@interest, status: :unprocessable_entity)
    end
  end
end
