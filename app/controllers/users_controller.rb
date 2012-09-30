class UsersController < ApplicationController
  skip_before_filter :require_token_auth, :only => [:authenticate, :create, :build_facebook_user]
  
  respond_to :json

  # The authorization method to give a user a token for auth.
  def authenticate
    is_facebook = params.has_key? :facebook_access_token
    is_regular = (params.keys & ['email', 'password']).count == 2

    unless is_facebook or is_regular
      return json_unauthorized 'You must specify either an email/password pair or facebook_access_token to authenticate.'
    end

    if is_facebook
      require 'koala'
      graph = Koala::Facebook::API.new(params[:facebook_access_token])
      
      # Perform a Facebook API call to see if the user exists.
      begin
        me = graph.get_object('me', { :fields => 'id' })
      rescue Koala::Facebook::APIError => exc
        return json_error "There was an API error from Facebook: #{exc}"
      end
      
      user = User.find_by_facebook_id(me['id'])

      # User not found?
      unless user
        return render json: { 
          :error => "A facebook user does not exist for the user associated with that access token.",
          :code => "NO_FACEBOOK_USER"
        }, :status => 401
      end
    
    elsif is_regular
      # Right now, find any user by an email address
      user = User.find_by_email(params[:email])

      # User not found?
      unless user
        return json_unauthorized 'A user does not exist for the email address specified.'
      end

      # Try and auth the user
      unless user.authenticate(params[:password])
        return json_unauthorized 'The password specified was incorrect.'
      end
    end
    
    # Update the users' facebook_access_token if possible.
    if is_facebook
      user.facebook_access_token = params[:facebook_access_token]
      user.save!
    end

    # We've got a user. Let's find or create the auth token and return it.
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
    @user = User.new

    # Allow editing the facebook_id and facebook_access token only for this request.
    @user.accessible = [:facebook_id, :facebook_access_token]

    # Update the user
    @user.update_attributes(params[:user])

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

  # Build and return an empty user from Facebookski
  def build_facebook_user
    unless params[:facebook_access_token]
      return json_error 'You must specify a facebook_access_token in order to build a user.'
    end

    @user = User.new
    @user.facebook_access_token = params[:facebook_access_token]
    @user.bootstrap_facebook_data

    respond_with @user
  end

end
