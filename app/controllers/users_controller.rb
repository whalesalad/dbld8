class UsersController < ApplicationController
  skip_filter :require_token_auth, :except => [:index, :show]

  before_filter :ensure_facebook_access_token, :only => [:authenticate, :create]
  after_filter :track_user_auth, :only => [:authenticate]
  
  respond_to :json

  def authenticate
    graph = Koala::Facebook::API.new(params[:facebook_access_token])

    begin
      me = graph.get_object('me', { :fields => 'id' })
    rescue Koala::Facebook::APIError => exc
      return json_error "There was an API error from Facebook: #{exc}"
    else
      @user = User.find_by_facebook_id(me['id'])

      if @user.nil?
        @user = FacebookUser.new
      end

      @user.accessible = [:facebook_access_token]
      @user.facebook_access_token = params[:facebook_access_token]
      
      if @user.save!
        render json: @user.token and return
      else
        respond_with(@user, status: :unprocessable_entity)
      end
    end
  end

  def index
    @users = User.all
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user
  end

  def invitation
    @user = if params[:invite_slug]
      User.find_by_invite_slug(params[:invite_slug])
    else
      false
    end

    render 'home/invite'
  end

  def ensure_facebook_access_token
    return json_error "A facebook_access_token is required." unless params[:facebook_access_token].present?
  end

  def track_user_auth
    Rails.logger.info "[ANALYTICS] User #{@user.id} logged in. Idenfiying + tracking login."

    # Identify the user
    Analytics.identify(user_id: @user.uuid, traits: @user.traits.merge({ '$ip' => request.remote_ip }))

    # Track the authentication
    Analytics.track(user_id: @user.uuid, event: 'User Login')
  end

end
