class Friendship < ActiveRecord::Base
  before_create :set_uuid
  
  attr_accessible :user_id, :approved, :friend_id
  
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  def set_uuid
    require 'uuid'
    uuid = UUID.new
    self.friendship_uuid = uuid.generate :compact
  end
  
end
