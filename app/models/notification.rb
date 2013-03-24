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
#  feed_item   :boolean         default(TRUE)
#

class Notification < ActiveRecord::Base
  include Concerns::UUIDConcerns

  after_commit :push_notification, :on => :create

  attr_accessible :user, :message_proxy, :event, :push, :unread, :callback

  belongs_to :user
  belongs_to :target, :polymorphic => true

  default_scope order('unread DESC, created_at DESC')

  scope :events, 
    where(:target_type => 'Event')
    .includes({
      :user => [:profile_photo]}, 
      {
        :target => [{ :related => [:user] }]
      }
    )

  scope :feed, where(:feed_item => true)
  scope :hidden, where(:feed_item => false)

  scope :unread, where(:unread => true)
  scope :read, where(:unread => false)

  def message?
    target_type == 'MessageProxy'
  end

  def event?
    !message?
  end

  def to_s
    if message?
      return "#{related.user.first_name}: #{related.to_s}"
    elsif target.is_a?(RegistrationEvent) || target.related.present?
      return target.notification_string_for(user)  
    end

    "Notification from #{target}"
  end

  def shortened_s
    s = to_s
    (s.size > 80) ? "#{s[0..80]}..." : s
  end

  def callback_url
    "#{Rails.configuration.ios_prefix}://#{target.notification_url}"
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

  def read!
    self.unread = false
    save!
  end

  def pushable?
    push? && unread? && !pushed?
  end

  def pushed!
    self.pushed = true
    save!
  end

  def photos
    target.photos
  end

  def has_dialog?
    target.respond_to?(:dialog)
  end

  def dialog
    (has_dialog?) ? target.dialog : nil
  end

  def push_notification
    PushNotificationWorker.perform_async(self.id)
  end

end
