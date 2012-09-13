class InterestsController < ApplicationController
  skip_before_filter :restrict_access, :only => [:index, :show]
  
  respond_to :json

  def index
    @interests = Interest.all

    respond_with params and return

    if params[:user_id]
      @user = User.find_by_id(params[:user_id])
      @interests = @user.interests.all
    end

    if params[:query]
      @interests = @interests.where('name ~* ?', params[:query])
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
