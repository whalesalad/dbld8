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
  after_commit :create_invite_event!, :on => :create
  
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_presence_of :user_id, :friend_id

  validate :unique_relationship?, :on => :create
  validate :user_is_not_inviting_himself?

  def self.find_for_user_or_friend(user_id)
    where('user_id = ? OR friend_id = ?', user_id, user_id)
  end

  def unique_relationship?
    errors.add(:user_id, "a friendship between these users already exists.") unless 
      self.class.where("(user_id = ? AND friend_id = ?) OR 
                        (user_id = ? AND friend_id = ?)",
                         user_id, friend_id, friend_id, user_id).empty?
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
    # Notification.send(...) if (self.published_changed? && self.published == true)
    create_recruit_events! if self.approved_changed? && self.approved == true
  end

  def as_json(options={})
    'BUILD'
    # exclude = [:updated_at, :user_id, :friend_id]
    # result = super({ :except => exclude }.merge(options))
    # result[:user] = user.as_json :mini => true
    # result[:friend] = friend.as_json :mini => true
    # result
  end

  private

  def create_invite_event!
    SentWingInviteEvent.create(:user => user, :related => self)
  end

  def create_recruit_events!
    RecruitedWingEvent.create(:user => user, :related => self)
    AcceptedWingInviteEvent.create(:user => friend, :related => self)
  end
  
end
