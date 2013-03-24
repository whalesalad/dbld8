class ActivitiesController < BaseActivitiesController
  before_filter :get_activity, :only => [:show, :update, :destroy]
  before_filter :activity_owner_only, :only => [:update, :destroy]

  def index
    params[:point] = if params[:latitude] && params[:longitude]
      "#{params[:latitude]},#{params[:longitude]}"
    else
      @authenticated_user.location.str_point
    end

    @activities = Activity.search(params)
    respond_with @activities
  end

  def mine
    @activities = @authenticated_user.activities
    respond_with(@activities, :template => 'activities/index')
  end

  def engaged
    @activities = base_activities.for_user_with_engagements(@authenticated_user)
    respond_with(@activities, :template => 'activities/index')
  end

  def show
    respond_with @activity
  end

  def create
    unlocker = MaxActivityUnlockerService.new(@authenticated_user)

    if unlocker.needs_unlock?
      payload = { 
        unlock: (unlocker.next_unlock_event) ? unlocker.next_unlock_event.json : false,
        activities_count: unlocker.activities_count,
        activities_allowed: unlocker.activities_allowed
      }

      payload[:highest_level_reached] = true if unlocker.highest_level?

      render json: payload and return
    end

    @activity = Activity.new(params[:activity])

    # Set the user
    @activity.user = @authenticated_user

    if @activity.save
      respond_with(@activity, 
        :status => :created, 
        :location => @activity, 
        :template => 'activities/show')
    else
      respond_with(@activity, :status => :unprocessable_entity)
    end
  end

  def update
    if @activity.update_attributes(params[:activity])
      respond_with(@activity, :template => 'activities/show')
    else
      respond_with(@activity, :status => :unprocessable_entity)
    end
  end

  def destroy
    respond_with(:nothing => true) if @activity.destroy
  end

  private

  def base_activities
    Activity.includes(:location, :user => [:profile_photo, :location], :wing => [:profile_photo, :location])
  end

  def activity_id
    params[:id]
  end

end