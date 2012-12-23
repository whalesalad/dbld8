class ActivitiesController < ApplicationController
  respond_to :json
  
  before_filter :get_activity, :only => [:show, :update, :destroy]
  before_filter :unauthorized!, :only => [:update, :destroy]
  before_filter :handle_activity_permissions, :only => [:update, :destroy]

  def index
    @activities = []

    Activity.search(params).each do |activity|
      # Update the relationship based on the current user.
      activity.update_relationship_as(@authenticated_user)
      # If the user can see the activity, add it to the list.
      # in this specific case, it's ensured that if the activity is engaged,
      # only the owner/wing or users who are engaged with it can see it.
      @activities << activity unless (activity.engaged? && (activity.relationship == Activity::IS_OPEN))
    end

    respond_with @activities
  end

  def mine
    @activities = @authenticated_user.my_activities
    respond_with @activities, :template => 'activities/index'
  end

  def engaged
    @activities = @authenticated_user.engaged_activities
    respond_with @activities, :template => 'activities/index'
  end

  def other
    @activities = Activity.where('user_id != ?', @authenticated_user.id)
    respond_with @activities, :template => 'activities/index'
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
