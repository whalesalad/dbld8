class LocationsController < ApplicationController
  skip_before_filter :restrict_access, :only => [:index, :show]
  
  respond_to :json

  def index
    @locations = Location.all

    # if params[:query]
      # @interests = @interests.where('name ~* ?', params[:query])
    # end

    respond_with @locations
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
