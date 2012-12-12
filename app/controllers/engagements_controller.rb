class EngagementsController < ApplicationController
  respond_to :json

  before_filter :get_activity
  before_filter :get_engagement, :only => [:show, :destroy]

  before_filter :activity_owners_only, :only => [:update]
  # before_filter :engagement_owners_only, :only => [:destroy]

  def index
    @engagements = if @activity.allowed?(@authenticated_user, :owner)
      @activity.engagements.not_ignored
    else
      [get_singular_engagement].compact
    end

    respond_with @engagements
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
    unauthorized! unless @engagement.allowed?(@authenticated_user, :all)

    unless @engagement.allowed?(@authenticated_user, :owners)
      # mark viewed if activity owners look at this
      @engagement.viewed!
    end

    respond_with @engagement
  end

  def destroy
    if @engagement.allowed?(@authenticated_user, :owner)
      # if the user is the owner of the engagement, actually delete it.
      if @engagement.destroy
        respond_with(:nothing => true) and return
      end
    elsif @activity.allowed?(@authenticated_user, :owner)
      # if the user is the owner of the activity, set status to ignored
      if @engagement.ignore!
        respond_with(:nothing => true) and return
      end
    end

    json_error "An error occured deleting this engagement."
  end

private

  def get_activity
    @activity = Activity.find_by_id(params[:activity_id])
    json_not_found "The requested activity was not found." if @activity.nil?
  end

  def get_engagement
    @engagement = if params[:id] == 'mine'
      get_singular_engagement
    else
      @activity.engagements.find_by_id(params[:id])      
    end

    json_not_found "You have not engaged in this activity yet, " \
      "or the engagement was not found." if @engagement.nil?
  end

  def get_singular_engagement
    @activity.engagements.find_by_user_id(@authenticated_user.id)
  end

  # only activity.participants can view index
  def activity_owners_only
    unauthorized! unless @activity.allowed?(@authenticated_user, :all)
  end

  def engagement_owners_only
    unauthorized! unless @engagement.allowed?(@authenticated_user, :owners)
  end

  def unauthorized!
    json_unauthorized "The authenticated user does not have" \
      "permission to do this."
  end

end
