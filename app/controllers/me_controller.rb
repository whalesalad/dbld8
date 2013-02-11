class MeController < ApplicationController  
  respond_to :json
  
  def show
    @user = @authenticated_user

    respond_with @user,
      :template => 'users/show'
  end

  def notifications
    @notifications = @authenticated_user.notifications
    
    respond_with @notifications,
      :template => 'notifications/index'
  end

  def update
    resp = if @authenticated_user.update_attributes(params[:user])
      { :template => 'users/show' }
    else
      { :status => :unprocessable_entity }
    end

    respond_with(@authenticated_user, resp)
  end

  def update_device_token
    @device = @authenticated_user.devices.find_or_create_by_token(params[:device_token])
    respond_with @device
  end

end
