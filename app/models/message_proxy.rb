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

  after_commit :notify, :on => :create

  belongs_to :user
  belongs_to :message
  
  has_one :notification,
    :as => :target,
    :dependent => :destroy

  def owners_proxy?
    message.user_id == user.id
  end

  def mark_read!
    self.unread = false
    save!
  end

  def notify
    # create notifications for each user unless this is the user who created the message.
    create_notification(:user => user, :push => true, :unread => unread) unless owners_proxy?
  end

  def notification_url
    message.notification_url
  end

  def app_identifier
    message.app_identifier
  end

  def photos
    message.photos
  end

end
