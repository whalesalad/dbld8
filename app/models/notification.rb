# == Schema Information
#
# Table name: notifications
#
#  id          :integer         not null, primary key
#  uuid        :uuid            not null
#  user_id     :integer         not null
#  unread      :boolean         default(TRUE)
#  push        :boolean         default(FALSE)
#  pushed      :boolean         default(FALSE)
#  callback    :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  target_id   :integer
#  target_type :string(255)     default("Event")
#

class Notification < ActiveRecord::Base
  include Concerns::UUIDConcerns

  after_commit :push_notification, :on => :create

  attr_accessible :user, :message_proxy, :event, :push, :unread, :callback

  # before_create :set_callback
  default_scope order('created_at DESC')

  scope :events, 
    where(:target_type => 'Event')
    .includes({
      :user => [:profile_photo]}, 
      {
        :target => [{ :related => [:user] }]
      }
    )

  scope :unread, where(:unread => true)
  scope :read, where(:unread => false)

  belongs_to :user
  
  belongs_to :target, 
    :polymorphic => true

  def message?
    target_type == 'MessageProxy'
  end

  def event?
    !message?
  end

  def to_s
    if message?
      return "#{related.user.first_name}: #{related.to_s}"
    elsif target.related.present?
      return target.notification_string_for(user)  
    end

    "Notification from #{target}"
  end

  def app_identifier
    target.app_identifier
  end

  def related
    message? ? target.message : target.related
  end

  def related_admin_path
    if message?
      [:admin, related.engagement]
    else
      target.related_admin_path
    end
  end

  def read?
    !unread?
  end

  def pushable?
    push? && unread? && !pushed?
  end

  def pushed!
    self.unread = false
    self.pushed = true
    save!
  end

  def photos
    target.photos
  end

  def set_callback
    # self.callback ||= 
    # if event.related.is_a?(Activity), open the activity
    # if event.is_a?(NewActivityEvent)
    # end
  end

  def push_notification
    PushNotificationWorker.perform_async(self.id)
  end

end
