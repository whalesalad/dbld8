# encoding: UTF-8
# == Schema Information
#
# Table name: friendships
#
#  id         :integer         not null, primary key
#  uuid       :uuid            not null
#  user_id    :integer         not null
#  friend_id  :integer         not null
#  approved   :boolean         default(FALSE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Friendship < ActiveRecord::Base
  before_create :set_uuid
  
  scope :approved, where(:approved => true)
  scope :unapproved, where(:approved => false)
  
  attr_accessible :user_id, :friend_id, :approved
  
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_presence_of :user_id, :friend_id

  validates_uniqueness_of :user_id, :scope => :friend_id, :message => "A friendship between these users already exists."
  # validates_uniqueness_of :friend_id, :scope => :user_id, :message => "A friendship between these users already exists."
  
  validate :user_is_not_inviting_himself
  # validates_uniqueness_of :friend_id, :scope => :user_id
  
  def to_s
    "#{user} ↔ #{friend}"
  end

  def user_is_not_inviting_himself
    errors.add(:friend_id, "can not be the same as User. You cannot become friends with yourself!") if user_id == friend_id
  end
  
  def set_uuid
    require 'securerandom'
    self.uuid = SecureRandom.uuid
  end

  def can_be_modified_by(inquiring_user)
    # Determines whether or not the user passed can perform actions on this friendship.
    (inquiring_user.id == user.id) || (inquiring_user.id == friend.id)
  end
  
  def approve!(approver)
    return true if self.approved
    
    if approver.id == friend_id
      self.approved = true
      self.save
    end
  end

  def as_json(options={})
    exclude = [:updated_at, :user_id, :friend_id]

    result = super({ :except => exclude }.merge(options))

    result[:user] = user.as_json :mini => true
    result[:friend] = friend.as_json :mini => true

    result
  end
  
end
