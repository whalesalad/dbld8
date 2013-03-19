# == Schema Information
#
# Table name: friendships
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  friend_id  :integer         not null
#  approved   :boolean         default(FALSE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Friendship < ActiveRecord::Base
  include Concerns::EventConcerns
  
  scope :approved, where(:approved => true)
  scope :unapproved, where(:approved => false)
  
  attr_accessible :user_id, :friend_id, :approved

  after_update :check_for_approved_changes
  after_commit :check_for_approved_on_create, :on => :create
  after_commit :create_invite_event!, :on => :create

  # Clean notifications
  after_commit :clean_facebook_notifications!, :on => :create
  
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_presence_of :user_id, :friend_id

  validate :unique_relationship?, :on => :create
  validate :user_is_not_inviting_himself?

  def self.find_for_user_or_friend(user_id)
    where('user_id = ? OR friend_id = ?', user_id, user_id)
  end

  def self.find_between_users(user_id, friend_id)
    where("(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)", user_id, friend_id, friend_id, user_id).first
  end

  def unique_relationship?
    unless self.find_between_users(user_id, friend_id).empty?
      errors.add(:user_id, "a friendship between these users already exists.") 
    end
  end
  
  def to_s
    "#{user} + #{friend}"
  end

  def user_is_not_inviting_himself?
    errors.add(:friend_id, "can not be the same as User. You cannot become friends with yourself!") if user_id == friend_id
  end
  
  def can_be_modified_by(inquiring_user)
    # Determines whether or not the user passed can perform actions on this friendship.
    (inquiring_user.id == user.id) || (inquiring_user.id == friend.id)
  end
  
  def approve!(approving_user)
    return true if approved?

    # Ensure only the receiving friend can approve friendship.
    if approving_user.id == friend_id
      self.approved = true
      save!
    end
  end

  def check_for_approved_changes
    if self.approved_changed? && self.approved == true
      create_recruit_events!  
      notifications.each do |n|
        n.read! if n.user_id == friend_id
      end
    end
  end

  def check_for_approved_on_create
    if self.approved == true
      create_recruit_events!
    end
  end

  def not_you(u)
    (u.id == user_id) ? friend : user
  end

  def as_json(options={})
    'BUILD'
  end

  def clean_facebook_notifications!
    notifications = []
    
    # Destroy the users notifications for the friend
    user_reg = user.events.where(type: 'RegistrationEvent').first
    notifications << user_reg.notifications.where(user_id: friend_id).first unless user_reg.nil?

    # Destroy the friends notifications for the user
    friend_reg = friend.events.where(type: 'RegistrationEvent').first
    notifications << friend_reg.notifications.where(user_id: user_id).first unless friend_reg.nil?

    notifications.compact.each { |n| n.destroy }
  end

  private

  def create_invite_event!
    SentWingInviteEvent.create(:user => user, :related => self)
  end

  def create_recruit_events!
    AcceptedWingInviteEvent.create(:user => friend, :related => self)
    RecruitedWingEvent.create(:user => user, :related => self)
  end
  
end
