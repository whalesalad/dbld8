class FacebookFriendService
  attr_accessor :user, :facebook_friends, :facebook_friend_ids, 
    :already_invited, :already_users, :invitable

  def initialize(user)
    @user = user
  end

  def facebook_friends
    # implement caching here to save this response
    @facebook_friends ||= user.facebook_graph.get_connections("me", "friends", { :fields => 'id,name,gender,location,picture' })
  end

  def facebook_friend_ids
    @facebook_friend_ids ||= facebook_friends.map {|f| f['id'].to_i }
  end

  def ignore_ids
    already_invited + already_users.pluck(:facebook_id)
  end

  def invitable
    @invitable ||= facebook_friends.reject do |fb_friend|
      ignore_ids.include? fb_friend['id'].to_i
    end.map { |fb_friend| FacebookFriend.new fb_friend }
  end

  def invitable_users
    already_users.delete_if { |e| user.find_any_friendship_with(e) } 
  end

  def already_invited
    @already_invited ||= FacebookInvite.where(:facebook_id => facebook_friend_ids).pluck(:facebook_id)
  end

  def already_users
    @already_users ||= User.where(:facebook_id => facebook_friend_ids)
  end

end

class FacebookFriend
  def initialize(fb_friend)
    @fb_friend = fb_friend
  end

  def to_s
    full_name
  end

  def full_name
    @fb_friend['name']
  end

  def gender
    @fb_friend['gender']
  end

  def facebook_id
    @fb_friend['id']
  end

  def photo
    { :thumb => @fb_friend['picture']['data']['url'].gsub('_q', '_n') }
  end

  def location
    @fb_friend['location']['name'] if @fb_friend.has_key? 'location'
  end

end