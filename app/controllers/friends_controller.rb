class FriendsController < ApplicationController
  # skip_before_filter :require_token_auth, :only => [:authenticate, :create, :build_facebook_user]
  
  respond_to :json
  
  def index
    respond_with @authenticated_user.friends.as_json(:mini => true)
  end

  def show
    @friend = User.find(params[:id])

    if @authenticated_user.find_any_friendship_with @friend
      respond_with @friend
    else
      json_unauthorized "You are not authorized to view this user."
    end
  end

end