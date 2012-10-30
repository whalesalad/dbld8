class Admin::ActivitiesController < AdminController
  before_filter :get_activity, :only => [:show, :edit, :update, :destroy]

  def index
    @activities = Activity.order('created_at DESC')
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
    @activity = Activity.find_by_id(params[:id])
  end
end