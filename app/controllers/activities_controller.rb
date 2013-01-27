class ActivitiesController < BaseActivitiesController
  respond_to :json
  
  before_filter :get_activity, :only => [:show, :update, :destroy]
  before_filter :activity_owner_only, :only => [:update, :destroy]

  def index
    params[:point] = if params[:latitude] && params[:longitude]
      "#{params[:latitude]},#{params[:longitude]}"
    else
      "#{@authenticated_user.location.latitude},#{@authenticated_user.location.longitude}"
    end

    @activities = Activity.search(params)
    # @activities = Activity.includes(:location, :user, :wing, :engagements).search(params)
    respond_with @activities
  end

  def mine
    # @activities = @authenticated_user.my_activities
    @activities = base_activities.for_user(@authenticated_user)
    respond_with(@activities, :template => 'activities/index')
  end

  def engaged
    # My activities that have engagements
    # Activities that I am a wing on that have engagements
    @activities = base_activities.for_user(@authenticated_user).with_engagements
    respond_with(@activities, :template => 'activities/index')
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
      respond_with @activity
    else
      respond_with @activity, :status => :unprocessable_entity
    end
  end

  def destroy
    respond_with(:nothing => true) if @activity.destroy
  end

  private

  def base_activities
    Activity.includes(:user, :wing, :location)
  end

  def activity_id
    params[:id]
  end

end