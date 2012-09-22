class Admin::InterestsController < AdminController
  before_filter :get_interest, :only => [:show, :edit, :update, :destroy]

  def index
    @interests = Interest.find(:all)
  end

  def show
    # respond_with
  end

  def destroy
    @interest.destroy
    redirect_to admin_interests_path, :flash => { :success => "Successfully deleted interest #{@interest}." }
  end

  protected

  def get_interest
    @interest = Interest.find_by_id(params[:id])
  end
end
