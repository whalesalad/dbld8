class MeController < ApplicationController  
  before_filter :get_user
  respond_to :json
  
  def show
    respond_with @user, :template => 'users/show'
  end

  def notifications
    @notifications = @user.notifications
    respond_with @notifications, :template => 'notifications/index'
  end

  def update
    if @user.update_attributes(params[:user])
      respond_with @user, :template => 'users/show'
    else
      respond_with(@user, status: :unprocessable_entity)
    end
  end

  def update_device_token
    @device = @authenticated_user.devices.find_or_create_by_token params[:device_token]
    respond_with @device
  end

  private

  def get_user
    @user = authenticated_user
  end
end
