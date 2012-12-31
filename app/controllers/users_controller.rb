class UsersController < ApplicationController
  skip_filter :require_token_auth, :except => [:index, :show]
  
  respond_to :json

  # The authorization method to give a user a token for auth.
  def authenticate
    auth = UserAuthenticator.from_params(params)

    if auth.authenticated?
      @token = auth.find_or_create_token
      render json: @token and return
    end
    
    # Finally, respond with the error if auth does not succeed.
    json_error auth.error
  end

  def index
    @users = User.all
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user
  end

  # POST
  def create
    @user = if params[:user].has_key?(:facebook_id)
      FacebookUser.new
    else
      EmailUser.new
    end

    # Allow editing the facebook_id and facebook_access token only for this request.
    @user.accessible = [:facebook_id, :facebook_access_token]

    if params[:user].has_key? 'invite_path'
      params[:user].delete 'invite_path'
    end

    # Update the user
    @user.update_attributes(params[:user])

    # We're creating a regular user
    if @user.is_a?(EmailUser)
      @user.password_confirmation = params[:user][:password]
    end

    if @user.save
      respond_with(@user, :status => :created, :location => user_path(@user), 
        :template => 'users/show')
    else
      respond_with(@user, status: :unprocessable_entity)
    end
  end

  # Build and return an empty user from Facebookski
  def build_facebook_user
    unless params[:facebook_access_token]
      return json_error 'You must specify a facebook_access_token in order to build a user.'
    end

    ActiveRecord::Base.uncached do
      @user = FacebookUser.new
      @user.facebook_access_token = params[:facebook_access_token]
      @user.bootstrap_facebook_data
    end

    respond_with @user, :template => 'users/show'
  end
  
  def invitation
    @user = false
    
    if params[:invite_slug]
      @user = User.find_by_invite_slug(params[:invite_slug])
    end
    
    render 'home/invite'
  end

end
