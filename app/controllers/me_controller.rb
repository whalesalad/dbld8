class MeController < ApplicationController  
  respond_to :json

  def show
    @user = authenticated_user
    respond_with @user, :template => 'users/show'
  end

  def update
    @user = authenticated_user

    if @user.update_attributes(params[:user])
      return respond_with @user
    else
      return respond_with(@user, status: :unprocessable_entity)
    end
  end

end
