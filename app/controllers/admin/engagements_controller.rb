class Admin::EngagementsController < AdminController
  before_filter :get_activity
  before_filter :get_engagement, :except => [:index]

  def index
    @activities = Activity.all
  end

  def engaged
    @activities = Activity.engaged
  end

  def expired
    @activities = Activity.expired
  end

  def show
    # respond_with
  end

  def destroy
    @activity.destroy
    redirect_to admin_activities_path, :flash => { :success => "Successfully deleted activity #{@activity.to_s}." }
  end

  private

  def get_activity
    @activity = Activity.find_by_id(params[:activity_id])
  end

  def get_engagement
    @engagement = @activity.engagements.find(params[:id])
  end
end
