# == Schema Information
#
# Table name: message_proxies
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  message_id :integer
#  unread     :boolean         default(TRUE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class MessageProxy < ActiveRecord::Base
  attr_accessible :user_id, :message_id, :unread

  # after_commit :notify, :on => :create

  has_one :user
  has_one :message
  
  # has_one :notification, :dependent => :destroy

  def owners_proxy?
    message.user_id == user_id
  end

  def mark_read!
    self.unread = false
    save!
  end

  def notify
    # create_notification(:user => user, :push => true, :unread => unread)
  end
end
