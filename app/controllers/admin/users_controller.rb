class Admin::UsersController < AdminController
  before_filter :get_user, :only => [:show, :photos, :edit, :update, :destroy]

  def index
    @users = User.order('created_at DESC')
  end

  def show

  end

  def photos
    
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, :flash => { :success => "Successfully deleted user #{@user.to_s}." }
  end

  protected

  def get_user
    @user = User.find_by_id(params[:id], :include => {:notifications => :target})
  end
end
