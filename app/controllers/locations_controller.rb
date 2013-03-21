class LocationsController < ApiController
  before_filter :set_point, :except => [:index, :show, :create]
  before_filter :get_location, :only => [:show]
  
  def index
    @locations = if params[:query]
      Location.where('name ~* ?', params[:query]).limit(50)
    else
      Location.limit(50)
    end

    respond_with @locations
  end

  def cities
    # @locations = if @latitude && @longitude
    #   Location.find_cities_near(@latitude, @longitude)
    # else
    #   Location.cities.where('name ~* ?', params[:query]).order('-population')
    # end

    @locations = Location.search({ :point => @point, :kind => 'city', :query => params[:query] })
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

  def set_point
    if (params.keys & %w(latitude longitude)).empty?
      @point = @authenticated_user.location.str_point
    elsif (params[:latitude] + params[:longitude]).to_i < 1
      return json_error "Please specify valid latitude and longitude parameters. lat: #{params[:latitude]}, lng: #{params[:longitude]} are invalid."
    end
    
    @point ||= [params[:latitude], params[:longitude]].join ','
  end

  def get_location
    @location = Location.find(params[:id])
  end
end
