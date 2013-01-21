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

    respond_with @activities
  end

  def mine
    @activities = @authenticated_user.my_activities
    respond_with(@activities, :template => 'activities/index')
  end

  def engaged
    @activities = @authenticated_user.engaged_activities
    respond_with(@activities, :template => 'activities/index')
  end

  def other
    @activities = Activity.where('user_id != ?', @authenticated_user.id)
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

  def activity_id
    params[:id]
  end

end