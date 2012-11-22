class EngagementsController < ApplicationController
  respond_to :json

  before_filter :get_engagement, :only => [:show, :destroy]
  before_filter :get_activity

  def index
    # render json: params and return
    # @engagements = 
    respond_with @activity.engagements
  end

  def create
    # @activity
    # @authenticated_user

    engagement = { :user_id => @authenticated_user.id }.merge(params[:engagement])

    @activity.engagements.create(engagement)
  end

  private

  def get_activity
    @activity = Activity.find_by_id(params[:activity_id])
  end

end
