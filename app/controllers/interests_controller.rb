class InterestsController < ApplicationController
  skip_before_filter :restrict_access, :only => [:index, :show]
  
  respond_to :json

  def index
    @interests = Interest.all

    if params[:query]
      @interests = Interest.where('name ~* ?', params[:query])
    end

    respond_with @interests
  end

  def show
    @interest = Interest.find(params[:id])
    respond_with @interest
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
