class EngagementsController < ApplicationController
  respond_to :json

  before_filter :get_activity
  before_filter :get_engagement, :only => [:show, :destroy]

  before_filter :handle_engagement_permissions, :only => [:index, :show]

  def index
    respond_with @activity.engagements 
  end

  def create
    @engagement = @activity.engagements.new(params[:engagement])
    @engagement.user = @authenticated_user

    if @engagement.save
      respond_with @engagement, :status => :created, :location => activity_engagement_path(@engagement)
    else
      respond_with @engagement, :status => :unprocessable_entity
    end    
  end

  def show
    respond_with @engagement
  end

private

  def get_activity
    @activity = Activity.find_by_id(params[:activity_id])
  end

  def get_engagement
    @engagement = @activity.engagements.find_by_id(params[:id])
  end

  def handle_engagement_permissions
    unless @activity.user == @authenticated_user  
      return json_unauthorized "The authenticated user does not have permission to manipulate engagements for this activity."
    end
  end

end
