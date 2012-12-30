class FriendsController < ApplicationController
  before_filter :find_friend, :only => [:destroy]
  
  respond_to :json
  
  def index
    @users = @authenticated_user.friends
    respond_with @users, :template => 'users/index'
  end

  def destroy
    @friendship = @authenticated_user.find_any_friendship_with(@friend)

    if @friendship.nil?
      return json_not_found "A friendship could not be found between this user and #{@friend} (User ID: #{@friend.id})."
    end

    if @friendship.destroy
      respond_with(:nothing => true)
    end
  end

  def facebook
    unless @authenticated_user.is_a?(FacebookUser)
      respond_with [] and return
    end

    respond_with filter_facebook_friends(@authenticated_user.facebook_friends)
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
    @friend = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return json_not_found "A friend with the ID of #{params[:id]} could not be found."
  end

  def filter_facebook_friends(facebook_friends = nil)
    return [] if facebook_friends.nil?

    friend_ids = facebook_friends.map { |f| f['id'] }
    already_invited = FacebookInvite.find_all_by_facebook_id(friend_ids, :select => :facebook_id).map(&:facebook_id)

    facebook_friends.select do |friend|
      # Clean up the ID
      friend['facebook_id'] = friend['id'].to_i
      friend.delete 'id'

      # continue unless this user has been invited
      next if already_invited.include? friend['facebook_id']

      # Clean up location
      if friend.has_key? 'location'
        friend['location'] = friend['location']['name']
      end

      # Clean up the photo
      if friend.has_key? 'picture'
        unless friend['picture']['data']['is_silhouette']
          friend['photo'] = { :thumb => friend['picture']['data']['url'].gsub('_q', '_n') }
        end
        friend.delete 'picture'
      end

      dbld8_user = User.find_by_facebook_id(friend['facebook_id'])

      unless dbld8_user.nil?
        friend['id'] = dbld8_user['id']
        friend['photo'] = dbld8_user.photo

        # Check and see if a friendship exists
        friendship = @authenticated_user.find_any_friendship_with(dbld8_user)
      end

      # Finally, return the frankenstein friend obj unless 
      # there is already a friendship
      friend unless friendship
    end
  end

end