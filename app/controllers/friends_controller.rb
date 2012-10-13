class FriendsController < ApplicationController
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

  def invite
    facebook_ids = []
    doubledate_users = []

    unless params[:facebook_ids].nil?
      facebook_ids = params[:facebook_ids].map { |id| id.to_i }
    end

    unless params[:user_ids].nil?
      doubledate_users = User.where(:id => params[:user_ids])
    end

    if facebook_ids.empty? && doubledate_users.empty?
      json_error("Please specify a valid array of facebook_ids or user_ids.") and return
    end

    dbld8_invited = 0
    fb_invited = 0

    facebook_ids.each do |fb_id|
      dbld8_user = User.find_by_facebook_id fb_id

      if dbld8_user && @authenticated_user.invite(dbld8_user)
        dbld8_invited += 1
      elsif @authenticated_user.facebook_invites.create(:facebook_id => fb_id)
        fb_invited += 1
      end
    end

    doubledate_users.each do |user|
      if @authenticated_user.invite(user)
        dbld8_invited += 1
      end
    end

    render :json => { 
      'dbld8_attempts' => doubledate_users.count,
      'fb_attempts' => facebook_ids.length,
      'dbld8_invited' => dbld8_invited,
      'fb_invited' => fb_invited,
      'total_invited' => dbld8_invited + fb_invited
    }

  end

  private

  def find_friend
    @friend = User.find_by_id(params[:id])

    if @friend.nil?
      json_not_found("A friend/user with the ID of #{params[:id]} could not be found.")
    end
  end

end