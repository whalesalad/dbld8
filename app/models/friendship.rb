class Friendship < ActiveRecord::Base
  before_create :set_uuid
  
  scope :approved, where(:approved => true)
  scope :unapproved, where(:approved => false)
  
  attr_accessible :user_id, :approved, :friend_id
  
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_uniqueness_of :user_id, :scope => :friend_id, :message => "A friendship between these users already exists."
  # validates_uniqueness_of :friend_id, :scope => :user_id
  
  def set_uuid
    require 'uuid'
    uuid = UUID.new
    self.friendship_uuid = uuid.generate :compact
  end
  
  def approve!(approver)
    return true if self.approved
    
    if approver.id == friend_id
      self.approved = true
      self.save
    end
  end
  
end
