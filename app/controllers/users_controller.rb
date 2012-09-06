class UsersController < ApplicationController
  skip_before_filter :restrict_access, :only => [:authenticate, :create]
  respond_to :json

  # The authorization method to give a user a token for auth.
  def authenticate
    is_facebook = (params.keys & ['facebook_id', 'access_token']).count == 2
    is_regular = (params.keys & ['email', 'password']).count == 2

    unless is_facebook or is_regular
      # return go die in a fire
    end

    if is_facebook
      require 'koala'
      graph = Koala::Facebook::API.new(params[:access_token])
      
      # Perform a facebook api call with the access token to /me
      me = graph.get_object('me', { :fields => 'id' })
      
      # If the resulting object user id matches :facebook_id, 
      unless me['id'] == params[:facebook_id]
        # Let's error out here, since the id's do not match.
        return json_error 'The facebook_id and access_token supplied do not validate.'
      end
      
      # find the user based on their facebook_id, then create&return an AuthToken
      user = User.find_by_facebook_id(params[:facebook_id])

      unless user
        return json_not_found 'A facebook user does not exist for that facebook_id.'
      end

      return render json: user

    end

    if is_regular
      # Find a user with the :email address.
      # Match the :password with the user.password_digest
      # return the user 
    end

    return render json: 'nope'
  end

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

    # We're creating a regular user
    if params[:password]
      @user.password_confirmation = params[:password]
    end

    # If a facebook_id or access_token exists
    params[:access_token]

    end

    if @user.save
      respond_with(@user, status: :created, location: @user)
    else
      respond_with(@user, status: :unprocessable_entity)
    end
  end

  # PUT
  def update
    @user = User.find(params[:id])

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
