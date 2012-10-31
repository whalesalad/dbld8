class Admin::LocationsController < AdminController
  before_filter :get_location, :only => [:show, :edit, :update, :destroy]

  def index
    @locations = Location.find(:all)
  end

  def show
    # respond_with
  end

  def destroy
    @location.destroy
    redirect_to admin_locations_path, :flash => { :success => "Successfully deleted location #{@location}." }
  end

  protected

  def get_location
    @location = Location.find_by_id(params[:id])
  end
end
