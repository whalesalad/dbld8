class FriendsController < ApiController
  before_filter :get_friend_and_friendship, :only => [:update, :destroy]
  
  def index
    @friendships = Friendship.find_for_user_or_friend(@authenticated_user)

    @users = @friendships.map do |friendship|
      user = friendship.not_you(@authenticated_user)
      user.approved = friendship.approved
      user.sort_date = friendship.created_at.to_i
      user
    end

    # Sort by the sort value
    @users.sort_by! { |u| - u.sort_date }

    respond_with @users, :template => 'users/index'
  end

  def update
    if @friendship.approve! @authenticated_user
      render json: { approved: true } and return
    end
    
    json_error "You do not have permission to approve this friendship."
  end

  def destroy
    # ensure that you do not have any dates or engagements with this person.
    has_activities = Activity.find_any_with_friendship(@friendship).any?
    has_engagements = Engagement.find_any_with_friendship(@friendship).any?

    if has_engagements || has_activities
      friend = @friendship.not_you(@authenticated_user)
      return json_error "You cannot remove #{friend} from your wings until your dates and messages with #{friend.pronoun} are cancelled."
    end

    respond_with(:nothing => true) if @friendship.destroy
  end

  def facebook
    unless @authenticated_user.is_a?(FacebookUser)
      respond_with(:nothing => true) and return
    end

    # Fire up FacebookFriendService to deal with parsing FB users
    friend_service = FacebookFriendService.new(@authenticated_user)

    # Respond with users who already exist in DBLD8, 
    # followed by fb_users who have not been invited yet and are not users.
    @users = friend_service.invitable_users + friend_service.invitable

    respond_with @users, :template => 'friends/facebook'
  end

  def invite
    # this is so nasty.
    facebook_ids = if params.has_key?(:facebook_ids) && !params[:facebook_ids].nil?
      params[:facebook_ids].map { |id| id if id.is_a?(Integer) }.compact 
    else
      []
    end

    unless facebook_ids.size > 0
      return json_error "Please specify an valid array of facebook_ids of users to invite."
    end

    doubledate_users = FacebookUser.where(:facebook_id => facebook_ids)

    doubledate_users.each do |user|
      @authenticated_user.invite(user)
    end
    
    # Remove doubledate users from facebook_ids
    facebook_ids = facebook_ids - doubledate_users.pluck(:facebook_id)

    facebook_ids.each do |facebook_id|
      @authenticated_user.facebook_invites.create(:facebook_id => facebook_id)
    end

    render :json => { 
      'total_invited' => doubledate_users.count + facebook_ids.count
    }
  end

  # Handles incoming invitations from regular users.
  def invite_connect
    # will accept an invite
    if params[:invite_slug].blank?
      return json_error "An invite_slug must be specified."
    end

    invite_slug = params[:invite_slug].to_s
    friend = User.find_by_invite_slug(invite_slug)

    if friend.nil?
      return json_error "A user could not be found for that invite_slug."
    end

    # automatically create a friendship between these two users
    friendship = friend.invite(@authenticated_user, true)

    if friendship
      respond_with friend, 
        :location => user_path(friend),
        :template => 'users/_user',
        :locals => { :user => friend } and return
    else
      respond_with friendship, :status => 422
    end
  end

  # Handles connecting incoming app requests from Facebook
  def request_connect
    if params[:request_ids].blank?
      return json_error "A string of Facebook request_ids must be specified."
    end

    fb_requests = @authenticated_user.facebook_graph.get_objects(params[:request_ids])

    @users = []

    fb_requests.each do |id, request|
      if request.has_key?('from')
        sender = FacebookUser.find_by_facebook_id(request['from']['id'])
      end

      if sender.present?
        sender.invite(@authenticated_user)

        # Add the friendshippies
        @users << sender

        # Delete the object
        # @authenticated_user.facebook_graph.delete_object("#{request['id']}_#{@authenticated_user.facebook_id}")
      end
    end

    respond_with @users, :template => 'users/index'
  end

  private

  def get_friend_and_friendship
    begin
      @friend = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return json_not_found "A user doesn't exist with id #{params[:id]}."
    end

    @friendship = @authenticated_user.find_any_friendship_with(@friend)

    if @friendship.nil?
      return json_not_found "A friendship doesn't exist between the authenticated user and <User ID:#{params[:id]}>"
    end
  end

end