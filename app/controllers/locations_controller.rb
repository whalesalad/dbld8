class LocationsController < ApplicationController
  skip_before_filter :require_token_auth, :only => [:index, :cities, :venues, :both, :show]
  
  before_filter :ensure_latlng, :only  => [:both, :cities, :venues]
  before_filter :get_location, :only => [:show]
  
  respond_to :json
  
  def index
    @locations = Location.find(:all)
    
    if params[:query]
      @locations = Location.where('name ~* ?', params[:query])
    end

    respond_with @locations
  end

  def cities
    @locations = Location.find_cities_near(@latitude, @longitude)
    respond_with @locations
  end

  def venues
    @locations = Location.find_venues_near(@latitude, @longitude, params[:query])
    respond_with @locations
  end

  def both
    @locations = Location.find_cities_and_venues_near(@latitude, @longitude, params[:query])
    respond_with @locations
  end

  def show
    respond_with @location
  end
  
  def create
    @location = Location.new(params[:location])

    if @location.save
      respond_with(@location, :status => :created, :location => @location)
    else
      respond_with(@location, :status => :unprocessable_entity)
    end
  end
  
  protected

  def ensure_latlng
    if (params.keys & %w(latitude longitude)).empty?
      json_error "Please specify latitude and longitude parameters."
    else
      @latitude = params[:latitude]
      @longitude = params[:longitude]
    end
  end

  def get_location
    @location = Location.find(params[:id])
  end
end
