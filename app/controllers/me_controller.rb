class MeController < ApplicationController  
  respond_to :json

  # The authorization method to give a user a token for auth.

  def me
    render json: authenticated_user
  end

  # GET /
  def index
    @users = User.all
    respond_with @users
  end

  # GET /<id>/
  def show
    @user = authenticated_user
    respond_with @user
  end

  # PUT
  def update
    @user = authenticated_user

    if params[:user][:interests]
      _interests = [ ]
      
      params[:user][:interests].each do |interest_name|
        _interests.append Interest.find_or_create_by_name(interest_name)
      end

      params[:user][:interests] = _interests
    end

    if @user.update_attributes(params[:user])
      return respond_with head: :no_content
    else
      return respond_with(@user, status: :unprocessable_entity)
    end
  end

  # DELETE
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
