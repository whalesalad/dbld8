class MeController < ApplicationController  
  respond_to :json

  # The authorization method to give a user a token for auth.
  def show
    @user = authenticated_user

    respond_with @user
  end

  def update
    @user = authenticated_user

    if @user.update_attributes(params[:user])
      return respond_with head: :no_content
    else
      return respond_with(@user, status: :unprocessable_entity)
    end
  end

  # def destroy
  #   @user = authenticated_user
    
  #   @user.destroy

  #   respond_with head: :no_content
  # end
end
