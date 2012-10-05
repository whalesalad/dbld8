class FriendsController < ApplicationController
  # skip_before_filter :require_token_auth, :only => [:authenticate, :create, :build_facebook_user]
  
  respond_to :json
  
  def index
    respond_with @authenticated_user.friends.as_json(:mini => true)
  end
end