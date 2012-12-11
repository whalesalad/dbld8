class ActivitiesController < ApplicationController
  respond_to :json
  
  before_filter :get_activity, :only => [:show, :update, :destroy]
  before_filter :handle_activity_permissions, :only => [:update, :destroy]

  def index
    @activities = Activity.search(params)

    @activities.each do |activity|
      activity.update_relationship_as(@authenticated_user)
    end
    
    respond_with @activities
  end

  def mine
    # - activities i've created (me.activities)
    # owned by me, type: owner
    
    # - activities a wing has created w/ me involved (me.participating_activities)
    # owned by wing, type: wing

    # - activities that i've shown interest in (engagement object created)
    # owned by someone else, type: engaged

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
    unauthorized!

    if @activity.update_attributes(params[:activity])
      return respond_with @activity
    else
      return respond_with @activity, :status => :unprocessable_entity
    end
  end

  def destroy
    unauthorized! 

    if @activity.destroy
      respond_with(:nothing => true)
    end
  end

private
  
  def get_activity
    @activity = Activity.find_by_id(params[:id])
  end

  def unauthorized!
    unless (@activity.user_id == @authenticated_user.id)
      return json_unauthorized "The authenticated user does not have permission to modify or delete this activity."
    end
  end

end
