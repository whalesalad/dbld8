class FriendsController < ApplicationController
  # skip_before_filter :require_token_auth, :only => [:authenticate, :create, :build_facebook_user]

  before_filter :find_friend, :only => [:show, :destroy]
  
  respond_to :json
  
  def index
    respond_with @authenticated_user.friends.as_json(:mini => true)
  end

  def show
    if @authenticated_user.find_any_friendship_with @friend
      respond_with @friend
    else
      json_unauthorized "You are not authorized to view this user."
    end
  end

  def destroy
    @friendship = @authenticated_user.find_any_friendship_with @friend

    if @friendship.nil?
      return json_not_found "A friendship could not be found between this user and #{@friend} (User ID: #{@friend.id})."
    end

    if @friendship.destroy
      respond_with(:nothing => true)
    end
  end

  def facebook
    unless @authenticated_user.facebook?
      respond_with [] and return
    end

    @facebook_friends = @authenticated_user.facebook_friends.map do |friend|
      friend['facebook_id'] = friend['id']
      friend.delete 'id'

      if friend.has_key? 'location'
        friend['location'] = friend['location']['name']
      end

      # Exclude users who are already your friend
      dbld8_user = User.find_by_facebook_id(friend['facebook_id'])

      unless dbld8_user.nil?
        friendship = @authenticated_user.find_any_friendship_with(dbld8_user)
        
        unless friendship.nil?
          friend['friendship_id'] = friendship.id
        end

        friend['id'] = dbld8_user['id']
      end

      friend
    end

    # Return all of a users facebook friends
    respond_with @facebook_friends
  end

  private

  def find_friend
    @friend = User.find_by_id(params[:id])

    if @friend.nil?
      json_not_found("A friend/user with the ID of #{params[:id]} could not be found.")
    end
  end

end