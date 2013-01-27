# == Schema Information
#
# Table name: messages
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  engagement_id :integer
#  message       :text
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class Message < ActiveRecord::Base
  attr_accessible :user, :message

  belongs_to :user
  belongs_to :engagement, :touch => true

  has_one :activity, :through => :engagement
  
  has_many :message_proxies, :dependent => :destroy

  default_scope order('messages.created_at ASC')

  scope :unread_for, lambda {|user| 
    joins(:message_proxies).where('message_proxies.user_id' => user.id).where('message_proxies.unread' => true)
  }

  def to_s
    message
  end

  def allowed?(a_user, permission = :all)
    a_user.id == user.id
    
    # at the moment this is all that can be done, regardless of permissions
    # case permission
    # when :owner
    #   a_user == user
    # end
  end

  def proxy_for(a_user)
    a_user = a_user.id if a_user.is_a?(User)
    message_proxies.find_by_user_id(a_user)
  end

  def unread_for(a_user=nil)
    proxy_for(a_user).unread? unless a_user.nil?
  end

  def mark_read!(a_user=nil)
    proxy_for(a_user).read! unless a_user.nil?
  end

  def as_json(options={})
    'BUILD'
  end

end
