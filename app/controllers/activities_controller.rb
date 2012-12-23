class ActivitiesController < ApplicationController
  respond_to :json
  
  before_filter :get_activity, :only => [:show, :update, :destroy]
  before_filter :unauthorized!, :only => [:update, :destroy]
  before_filter :handle_activity_permissions, :only => [:update, :destroy]

  def index
    @activities = []

    Activity.search(params).each do |activity|
      activity.update_relationship_as(@authenticated_user)
      @activities << activity unless (activity.engaged? && (activity.relationship == Activity::IS_OPEN))
    end

    # reject activities you cannot see based on the relationship
    # @activities.reject! do |activity|

    # end

    respond_with @activities
  end

  def mine
    # - activities that i've shown interest in and are accepted
    # TODO owned by someone else, type: accepted 
    respond_with @authenticated_user.my_activities
  end

  def engaged
    respond_with @authenticated_user.engaged_activities
  end

  def other
    respond_with Activity.where('user_id != ?', @authenticated_user.id)
  end

  def show
    respond_with @activity
  end

  def create
    @activity = Activity.new(params[:activity])

    # Set the user
    @activity.user = @authenticated_user

    if @activity.save
      respond_with @activity, :status => :created, :location => @activity
    else
      respond_with @activity, :status => :unprocessable_entity
    end
  end

  def update
    if @activity.update_attributes(params[:activity])
      return respond_with @activity
    else
      return respond_with @activity, :status => :unprocessable_entity
    end
  end

  def destroy
    if @activity.destroy
      respond_with(:nothing => true)
    end
  end

private
  
  def get_activity
    @activity = Activity.find(params[:id])
    
    rescue ActiveRecord::RecordNotFound
      return json_not_found "The requested activity was not found."

    @activity.update_relationship_as(@authenticated_user)
  end

  def unauthorized!
    unless @activity.allowed?(@authenticated_user, :owner)
      json_unauthorized "The authenticated user does not have " \
        "permission to modify or delete this activity." 
    end
  end

end
