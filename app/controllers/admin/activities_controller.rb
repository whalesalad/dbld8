class Admin::ActivitiesController < AdminController
  before_filter :get_activity, :only => [:show, :edit, :update, :destroy]

  def index
    @title = 'Activities'
    @activities = base_activities.all
  end

  def engaged
    @title = 'Engaged Activities'
    @activities = base_activities.engaged
  end

  def expired
    @title = 'Expired Activities'
    @activities = base_activities.expired
  end

  def show
    # respond_with
  end

  def destroy
    @activity.destroy
    
    redirect_to admin_activities_path, 
      :flash => { :success => "Successfully deleted activity #{@activity.to_s}." }
  end

  private

  def base_activities
    Activity.includes(:user, :wing, :location, {:engagements => [:user, :wing]}).unscoped.order('created_at DESC')
  end

  def get_activity
    @activity = Activity.find_by_id(params[:id])
  end
end
