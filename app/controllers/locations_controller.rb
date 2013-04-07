class LocationsController < ApiController
  before_filter :set_point, :except => [:index, :show, :create]
  before_filter :get_location, :only => [:show]
  after_filter  :set_empty_location, :only => [:current]
  
  def index
    @locations = if params[:query]
      Location.where('name ~* ?', params[:query]).limit(50)
    else
      Location.limit(50)
    end

    respond_with @locations
  end

  def cities
    @locations = Location.search({ 
      :point => @point, 
      :kind => 'city', 
      :query => params[:query], 
      :distance => params[:distance] 
    })
    respond_with @locations, :template => 'locations/index'
  end

  def venues
    @locations = Location.find_venues_near(@point, params[:query])
    respond_with @locations, :template => 'locations/index'
  end

  def current
    @location = Location.search({ :point => @point, :kind => 'city' }).first
    respond_with @location, :template => 'locations/show'
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

  # If the user does not have a location set, we will use this to do so.
  def set_empty_location
    if @authenticated_user.location.blank? && @location.present?
      @authenticated_user.location = @location
      @authenticated_user.save
    end
  end

  def get_location
    @location = Location.find(params[:id])
  end
end
