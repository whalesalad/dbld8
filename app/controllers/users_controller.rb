class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # GET /
  def index
    @users = User.all
    respond_with @users
  end

  # GET /<id>/
  def show
    @user = User.find(params[:id])
    respond_with @user
  end

  # POST
  def create
    @user = User.new(params[:user])

    if @user.save
      respond_with @user, status: :created, location: @user
    else
      respond_with @user.errors, status: :unprocessable_entity
    end
  end

  # PUT
  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      return respond_with head: :no_content
    else
      return respond_with @user.errors, status: :unprocessable_entity
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
