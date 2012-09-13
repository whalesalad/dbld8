class UsersController < ApplicationController
  skip_before_filter :restrict_access, :only => [:authenticate, :create]
  
  respond_to :json

  # The authorization method to give a user a token for auth.
  def authenticate
    is_facebook = (params.keys & ['facebook_id', 'facebook_access_token']).count == 2
    is_regular = (params.keys & ['email', 'password']).count == 2

    unless is_facebook or is_regular
      return json_error 'You must specify either an email/password or facebook_id/facebook_access_token pair to authenticate.'
    end

    if is_facebook
      require 'koala'
      graph = Koala::Facebook::API.new(params[:facebook_access_token])
      
      # Perform a facebook api call with the access token to /me
      me = graph.get_object('me', { :fields => 'id' })
      
      # If the resulting object user id matches :facebook_id, 
      unless me['id'] == params[:facebook_id]
        # Let's error out here, since the id's do not match.
        return json_error 'The facebook_id and facebook_access_token supplied do not validate.'
      end
      
      # find the user based on their facebook_id, then create&return an AuthToken
      user = User.find_by_facebook_id(params[:facebook_id])

      unless user
        return json_not_found 'A facebook user does not exist for that facebook_id.'
      end
      # at this point we have a user.
    elsif is_regular
      # Right now, find any user by an email address and just 
      user = User.find_by_email(params[:email])

      unless user
        return json_not_found 'A user does not exist for the email address specified.'
      end

      unless user.authenticate(params[:password])
        return json_error 'The password specified was incorrect.'
      end
    end

    # At this point we have a user. Let's find or create the auth token and return it.
    @token = AuthToken.find_or_create_by_user_id(user.id)

    return render json: @token
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
    if params[:user][:password]
      @user.password_confirmation = params[:user][:password]
    end

    if @user.save
      respond_with(@user, status: :created, location: @user)
    else
      respond_with(@user, status: :unprocessable_entity)
    end
  end

  def build_from_facebook
    # build and respond with an empty user from facebook
    @user = User.new(params[:user])
    @user.bootstrap_facebook_data

    respond_with @user
  end

  # DELETE
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_with head: :no_content
  end
end
