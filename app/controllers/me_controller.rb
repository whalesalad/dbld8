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

  private

  def get_user
    @user = authenticated_user
  end
end
