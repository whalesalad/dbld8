class MeController < ApplicationController  
  respond_to :json
  before_filter :set_user
  
  def show
    respond_with @user,
      :template => 'users/show'
  end

  def update
    resp = if @user.update_attributes(params[:user])
      { :template => 'users/show' }
    else
      { :status => :unprocessable_entity }
    end

    respond_with(@user, resp)
  end

  def update_device_token
    @device = @user.devices.find_or_create_by_token(params[:device_token])
    respond_with @device
  end

  private

  def set_user
    @user = @authenticated_user
  end

end
