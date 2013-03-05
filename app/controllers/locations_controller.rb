class LocationsController < ApplicationController
  respond_to :json

  skip_filter :require_token_auth, :only => [:index, :cities, :venues, :both, :show]
  
  before_filter :ensure_latlng, :only  => [:both, :venues]
  before_filter :get_location, :only => [:show]
  
  def index
    @locations = if params[:query]
      Location.where('name ~* ?', params[:query])
    else
      Location.find(:all)
    end

    respond_with @locations
  end

  def cities
    ensure_latlng unless params[:query].present?
    
    @locations = if @latitude && @longitude
      Location.find_cities_near(@latitude, @longitude)
    else
      Location.cities.where('name ~* ?', params[:query]).order('-population')
    end

    respond_with @locations, :template => 'locations/index'
  end

  def venues
    @locations = Location.find_venues_near(@latitude, @longitude, params[:query])
    respond_with @locations, :template => 'locations/index'
  end

  def both
    @locations = Location.find_cities_and_venues_near(@latitude, @longitude, params[:query])
    respond_with @locations, :template => 'locations/index'
  end

  def show
    respond_with @location
  end
  
  def create
    @location = Location.new(params[:location])

    if @location.save
      respond_with(@location, :status => :created, :location => @location, :template => 'locations/show')
    else
      respond_with(@location, :status => :unprocessable_entity)
    end
  end
  
  protected

  def ensure_latlng
    if (params.keys & %w(latitude longitude)).empty?
      return json_error "Please specify latitude and longitude parameters, or a query parameter if searching for cities."
    elsif (params[:latitude] + params[:longitude]).to_i < 1
      return json_error "Please specify valid latitude and longitude parameters. lat: #{params[:latitude]}, lng: #{params[:longitude]} are invalid."
    else
      @latitude = params[:latitude]
      @longitude = params[:longitude]
    end
  end

  def get_location
    @location = Location.find(params[:id])
  end
end
