class LocationsController < ApplicationController
  skip_before_filter :require_token_auth, :only => [:index, :show, :search]
  before_filter :get_location, :only => [:show]
  
  respond_to :json
  
  def index
    @locations = Location.all
    respond_with @locations
  end


  def search
    @locations = []
    
    if params[:latitude] and params[:longitude]
      # we're doing a geo query!!!
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
