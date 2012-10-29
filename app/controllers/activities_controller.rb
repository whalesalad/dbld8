class ActivitiesController < ApplicationController
  respond_to :json
  # skip_before_filter :require_token_auth, :only => [:index, :show]
  
  before_filter :get_activity, :only => [:show, :destroy]

  def index
    @activities = Activity.all
    respond_with @activities
  end

  def mine
    # @activities = Activity.find_by_user_id(@authenticated_user.id)
    respond_with @authenticated_user.all_my_activities
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

  def destroy
    unless (@activity.user_id == @authenticated_user.id)
      return json_unauthorized "The authenticated user does not have permission to delete this activity."
    end

    if @activity.destroy
      respond_with(:nothing => true)
    end
  end

  private

  def get_activity
    @activity = Activity.find_by_id(params[:id])
  end

end
