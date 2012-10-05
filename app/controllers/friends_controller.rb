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

  private

  def find_friend
    @friend = User.find_by_id(params[:id])

    if @friend.nil?
      json_not_found("A friend/user with the ID of #{params[:id]} could not be found.")
    end
  end

end