class InterestsController < ApplicationController
  skip_filter :require_token_auth, :only => [:index, :show]
  before_filter :get_interest, :only => [:show]
  
  respond_to :json

  def index
    @interests = if params[:query]
      Interest.where('name ~* ?', params[:query])
    else
      Interest.find(:all)
    end

    # Elasticsearch
    # @interests = if params[:query]
    #   Interest.search(params)
    # else
    #   Interest.limit(50)
    # end

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

    if @interest.nil?
      json_not_found("An interest with an ID of #{params[:id]} could not be found.")
    end
  end
end
