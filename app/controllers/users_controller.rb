class UsersController < ApplicationController
  skip_filter :require_token_auth, :except => [:index, :show]
  
  respond_to :json

  # The authorization method to give a user a token for auth.
  def authenticate
    auth = UserAuthenticator.from_params(params)

    if auth.authenticated?
      @token = auth.find_or_create_token
      track_user_auth(auth.user)
      render json: @token and return
    end
    
    # Finally, respond with the error if auth does not succeed.
    render json: auth.error, :status => 401 and return
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
    if @user.is_a?(FacebookUser)
      @user.accessible = [:facebook_id, :facebook_access_token]
    end

    # Update the user
    @user.update_attributes(params[:user].except('invite_path', 'age'))

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

    respond_with @user, :template => 'users/bootstrap'
  end
  
  def invitation
    @user = false
    
    if params[:invite_slug]
      @user = User.find_by_invite_slug(params[:invite_slug])
    end
    
    render 'home/invite'
  end

  def track_user_auth(user)
    Rails.logger.info "[ANALYTICS] User #{user.id} logged in. Idenfiying + tracking login."

    # Identify the user
    $segmentio.identify(user_id: user.uuid, traits: user.traits.merge({ '$ip' => request.remote_ip }))

    # Track the authentication
    $segmentio.track(user_id: user.uuid, event: 'User Login')
  end

end
