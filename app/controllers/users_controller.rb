class UsersController < ApiController
  skip_filter :require_token_auth, :only => [:authenticate]
  
  before_filter :ensure_facebook_access_token, :only => [:authenticate]
  before_filter :get_user, :only => [:show, :invite]

  after_filter :track_user_auth, :only => [:authenticate]

  def index
    @users = User.all
    respond_with @users
  end

  def show
    respond_with @user
  end

  def authenticate
    graph = Koala::Facebook::API.new(params[:facebook_access_token])

    begin
      me = graph.get_object('me', { :fields => 'id' })
    rescue Koala::Facebook::APIError => exc
      return json_error t('users.facebook_auth_error', facebook_error: exc)
    else
      @user = User.find_by_facebook_id(me['id'])

      @new_user = @user.nil?
      
      if @new_user
        @user = FacebookUser.new
      else
        FacebookSyncWorker.perform_async(@user.id)
      end

      @user.accessible = [:facebook_access_token]
      @user.facebook_access_token = params[:facebook_access_token]
      
      if @user.save!
        @authenticated_user = @user
        @user.create_token if @user.token.blank?
        render json: @user.token.as_json.merge(new_user: @new_user) and return
      else
        respond_with(@user, status: :unprocessable_entity)
      end
    end
  end

  def logout
    @authenticated_user.logout!
    Analytics.track(user_id: @authenticated_user.uuid, event: 'User Logout')
    render json: { logged_out: true } and return
  end

  def invite
    @friendship = @authenticated_user.invite(@user)
    render json: { success: !!@friendship }
  end

  private

  def get_user
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return json_record_not_found(User, params[:id])
    end
  end

  def ensure_facebook_access_token
    return json_missing_parameter('facebook_access_token') unless params[:facebook_access_token].present?
  end

  def track_user_auth
    Rails.logger.info("[AUTH] Login failure.") and return if @user.blank?
    Rails.logger.info "[ANALYTICS] User #{@user.id} logged in. Idenfiying + tracking login."

    # Identify the user
    Analytics.identify(user_id: @user.uuid, traits: @user.traits.merge({ '$ip' => request.remote_ip }))

    # Track the authentication
    Analytics.track(user_id: @user.uuid, event: 'User Login')
  end

end
