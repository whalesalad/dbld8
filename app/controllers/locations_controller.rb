class LocationsController < ApplicationController
  skip_before_filter :require_token_auth, :only => [:index, :show]
  before_filter :get_location, :only => [:show]
  
  respond_to :json
  
  def index
    @locations = Location.find(:all)
    
    if params[:query]
      @locations = Location.where('name ~* ?', params[:query])
    elsif params[:latitude] && params[:longitude]
      @locations = Location.find_near_point(params[:latitude], params[:longitude])
    end

    respond_with @locations
  end

  def show
    respond_with @location
  end
  
  def create
    @location = Location.new(params[:location])

    if @location.save
      respond_with(@location, status: :created, location: @location)
    else
      respond_with(@location, status: :unprocessable_entity)
    end
  end
  
  protected

  def get_location
    @location = Location.find(params[:id])
  end
end
