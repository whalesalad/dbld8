class DevController < ApplicationController
  skip_before_filter :require_token_auth, :all
  
  respond_to :html, :json

  def users
    @users = User.find(:all)
    respond_with @users
  end

  def user_detail
    @user = User.find_by_id(params[:id])
    respond_with @user
  end

end
