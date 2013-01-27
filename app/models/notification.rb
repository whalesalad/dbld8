# == Schema Information
#
# Table name: notifications
#
#  id         :integer         not null, primary key
#  uuid       :uuid            not null
#  user_id    :integer         not null
#  event_id   :integer         not null
#  unread     :boolean         default(TRUE)
#  push       :boolean         default(FALSE)
#  pushed     :boolean         default(FALSE)
#  callback   :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Notification < ActiveRecord::Base
  include Concerns::UUIDConcerns

  after_commit :push_notification, :on => :create

  attr_accessible :user, :message_proxy, :event, :push, :unread, :callback

  # before_create :set_callback
  default_scope order('created_at DESC')

  belongs_to :user
  belongs_to :event

  belongs_to :target, :polymorphic => true

  def message?
    target_type == 'MessageProxy'
  end

  def event?
    !message?
  end

  def to_s
    if message?
      return "#{related.user.first_name}: #{related.to_s}"
    end

    if target.related.present?
      # NEW ACTIVITY
      if target.is_a?(NewActivityEvent) && user == related.wing
        return "You're #{related.user.first_name}'s wing on #{related.user.gender_posessive} DoubleDate \"#{related}\"."
      end

      # NEW ENGAGEMENT
      if target.is_a?(NewEngagementEvent)
        # if the user is the engagement wing
        if user == related.wing
          return "#{related.user} picked you to be #{related.user.gender_posessive} wing on the DoubleDate \"#{related.activity}\""
        end

        # if the user is a participant
        if related.activity.participant_ids.include?(user.id)
          return "#{related.participant_names} are interested in \"#{related.activity}\""
        end
      end

      if target.is_a?(SentWingInviteEvent)
        return "#{related.user} invited you to be #{related.user.gender_posessive} wing."
      end

      if target.is_a?(RecruitedWingEvent)
        return "#{related.friend} accepted your wing invitation!"
      end
    end

    "Notification from #{target}"
  end

  def callback_str
    "dbld8://#{target.class.model_name.parameterize}/#{target.id}"
  end

  def related
    message? ? target.message : target.related
  end

  def related_admin_path
    if message?
      # admin_activity_engagement_path
      [:admin, related.engagement.activity, related.engagement]
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
