class EngagementsController < ApplicationController
  respond_to :json

  before_filter :get_activity
  before_filter :get_engagement, :only => [:show, :destroy]

  before_filter :activity_owners_only, :only => [:index, :update]
  before_filter :engagement_owners_only, :only => [:destroy]

  def index
    respond_with @activity.engagements 
  end

  def create
    @engagement = @activity.engagements.new(params[:engagement])
    @engagement.user = @authenticated_user

    if @engagement.save
      respond_with @engagement, :status => :created, :location => activity_engagement_path(@activity, @engagement)
    else
      respond_with @engagement, :status => :unprocessable_entity
    end    
  end

  def show
    # A user needs to be one of the four allowed to see this.
    unauthorized! unless @engagement.allowed(@authenticated_user, :all)

    unless @engagement.allowed(@authenticated_user, :owners)
      # mark viewed if activity owners look at this
      @engagement.mark_viewed!
    end

    respond_with @engagement
  end

  def destroy
    if @engagement.destroy
      respond_with(:nothing => true)
    else
      json_error "An error occured deleting this engagement."
    end
  end

private

  def get_activity
    @activity = Activity.find_by_id(params[:activity_id])
  end

  def get_engagement
    if params[:id]
      # direct /engagements/:id/
      @engagement = @activity.engagements.find_by_id(params[:id])
    else
      # singular resource, /engagement
      @engagement = @activity.engagements.find_by_user_id(@authenticated_user.id)
    end

    if @engagement.nil?
      return json_not_found "You have not engaged in this activity yet, or the engagement was not found."
    end
  end

  # only activity.participants can view index
  def activity_owners_only
    unless @activity && @activity.allowed(@authenticated_user, :all)
      unauthorized!
    end
  end

  def engagement_owners_only
    unless @engagement && @engagement.allowed(@authenticated_user, :owners)
      unauthorized!
    end
  end

  def unauthorized!
    json_unauthorized "The authenticated user does not have permission to do this." and return
  end

end
