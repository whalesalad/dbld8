class Notification < ActiveRecord::Base
  include Concerns::UUIDConcerns

  attr_accessible :user, :message_proxy, :event, :push, :callback

  # before_create :set_callback
  default_scope order('created_at DESC')

  belongs_to :user
  belongs_to :event

  def to_s
    if event.related.present?
      # NEW ACTIVITY
      if event.is_a?(NewActivityEvent) && user == target.wing
        return "You're #{event.activity.user.first_name}'s wing on #{event.activity.user.gender_posessive} DoubleDate \"#{event.activity}\"."
      end

      # NEW ENGAGEMENT
      if event.is_a?(NewEngagementEvent)
        # if the user is the engagement wing
        if user == target.wing
          return "#{target.user} picked you to be #{target.user.gender_posessive} wing on the DoubleDate \"#{target.activity}\""
        end

        # if the user is a participant
        if target.activity.participant_ids.include?(user.id)
          return "#{target.participant_names} are interested in \"#{target.activity}\""
        end
      end

      if event.is_a?(SentWingInviteEvent)
        return "#{target.user} invited you to be #{target.user.gender_posessive} wing."
      end

      if event.is_a?(RecruitedWingEvent)
        return "#{target.friend} accepted your wing invitation!"
      end
    end

    "Notification from #{event}"
  end

  def callback_str
    "dbld8://#{target.class.model_name.parameterize}/#{target.id}"
  end

  def target
    event.related
  end

  def read?
    !unread?
  end

  def set_callback
    # self.callback ||= 
    # if event.related.is_a?(Activity), open the activity
    # if event.is_a?(NewActivityEvent)
    # end
  end

end