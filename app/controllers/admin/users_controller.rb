class Admin::UsersController < AdminController
  before_filter :get_user, :except => [:index]

  def index
    @users = User.includes(:location, :profile_photo).order('created_at DESC').page(params[:page]).per(30)
  end

  def show

  end

  def photos
    
  end

  def send_push
    notification_ids = @user.notifications.map do |n|
      n.id if n.has_dialog?
    end.compact

    push = PushNotificationWorker.perform_async(notification_ids.sample, true)

    render json: { push: push } and return
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
