class InterestsController < ApplicationController
  skip_before_filter :require_token_auth, :only => [:index, :show]
  before_filter :get_interest, :only => [:show]
  
  respond_to :json

  def index
    @interests = Interest.find(:all)

    if params[:query]
      @interests = Interest.where('name ~* ?', params[:query])
    end

    respond_with @interests
  end

  def show
    respond_with @interest
  end

  def create
    @interest = Interest.new(params[:interest])

    if @interest.save
      respond_with(@interest, status: :created, location: @interest)
    else
      respond_with(@interest, status: :unprocessable_entity)
    end
  end

  protected

  def get_interest
    @interest = Interest.find(params[:id])
  end
end
