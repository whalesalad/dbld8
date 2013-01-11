class FriendsController < ApplicationController
  respond_to :json
  
  before_filter :get_friend_and_friendship, :only => [:update, :destroy]
  
  def index
    # Get all approved wings
    approved = @authenticated_user.friends.each do |friend|
      friend.approved = true
    end

    # Get all unapproved users
    unapproved = @authenticated_user.pending_friends.each do |pending|
      pending.approved = false
    end

    # Combine both lists, unapproved being first.
    @users = unapproved + approved

    respond_with @users, :template => 'users/index'
  end

  def update
    if @friendship.approve! @authenticated_user
      render json: { approved: true } and return
    end
    
    json_error "You do not have permission to approve this friendship."
  end

  def destroy
    if @friendship.destroy
      respond_with(:nothing => true)
    end
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
      params[:facebook_ids].map { |id| id if id.is_a? Fixnum }.compact 
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