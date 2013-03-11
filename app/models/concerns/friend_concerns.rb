module Concerns
  module FriendConcerns
    extend ActiveSupport::Concern

    included do
      # Handle the friendship relationships (the intermediary)
      has_many :friendships, 
        :include => [:user, :friend],
        :dependent => :destroy

      has_many :inverse_friendships, 
        :class_name => "Friendship", 
        :foreign_key => "friend_id", 
        :include => [:user, :friend],
        :dependent => :destroy

      # This gets direct (you are user_id) and inverse (you are friend_id) user objects
      has_many :direct_friends, 
        :through => :friendships, 
        :conditions => { :'friendships.approved' => true },
        :include => [:profile_photo, :location],
        :source => :friend
      
      has_many :inverse_friends, 
        :through => :inverse_friendships, 
        :conditions => { :'friendships.approved' => true },
        :include => [:profile_photo, :location],
        :source => :user

      # Friends I have asked to be mine
      has_many :requested_friends,
        :through => :friendships,
        :conditions => { :'friendships.approved' => false },
        :foreign_key => "user_id", 
        :source => :friend

      # Pending friends that I need to say yes/no to
      has_many :pending_friends,
        :through => :inverse_friendships,
        :conditions => { :'friendships.approved' => false },
        :foreign_key => "friend_id",
        :source => :user
    end

    # Invite a friend if that friend is not this user and a friendship does not exist
    def invite(friend, approve = nil)
      return false if friend == self

      friendship = find_any_friendship_with(friend)
      
      if friendship.present?
        friendship.approved = true
      else
        friendship = friendships.build({ :friend_id => friend.id })
      end

      if approve == true
        friendship.approved = true
      end

      return friendship.save! ? friendship : false
    end

    def invited?(friend)
      friendship = find_any_friendship_with(friend)
      return false if friendship.nil?
      friendship.friend == user
    end

    def approve(friend)
      friendship = find_any_friendship_with(friend)
      return false if friendship.nil? || invited?(friend)
      friendship.update_attribute(:approved, true)
    end

    def find_any_friendship_with(user)
      user_id = (user.instance_of?(User)) ? user.id : user
      Friendship.where(:user_id => id, :friend_id => user.id).first || Friendship.where(:user_id => user.id, :friend_id => id).first
    end

    def friends
      # reload
      friends = direct_friends + inverse_friends
    end

    def total_friends
      direct_friends(false).count + inverse_friends(false).count
    end

  end
end
