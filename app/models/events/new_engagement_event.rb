# == Schema Information
#
# Table name: events
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  type         :string(255)
#  coins        :integer
#  related_id   :integer
#  related_type :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  karma        :integer         default(0)
#

class NewEngagementEvent < Event
  alias engagement related

  earns 0

  def participants
    if engagement.present?
      engagement.participant_names
    else
      User.model_name.pluralize
    end
  end

  def activity
    if engagement.present?
      engagement.activity
    else
      "an #{Activity.model_name.singular}"
    end
  end

  def notification_string_for(user)
    if user == engagement.wing
      return nt(:for_wing,
        engagement_creator: engagement.user,
        his_or_her: engagement.user.gender_posessive,
        activity: engagement.activity.to_s
      )
    end

    if engagement.activity.participant_ids.include?(user.id)
      return nt(:for_activity_users, 
        engagement_users: engagement.participant_names,
        activity: engagement.activity.to_s
      )
    end
  end

  def detail_string_params
    {
      participants: participants,
      activity: activity
    }
  end

  def notify
    # two events are created, so only do this if this is the creator event
    if user == engagement.user
      # Send notification to [user, wing] on the Activity
      engagement.activity.participants.each do |u|
        Rails.logger.debug "Sending an engagement event to #{u.id}:#{u.first_name}"
        notifications.create(:user => u, :push => true)
      end

      # Send notification to the [wing] on the Engagement
      # Vanessa picked you to be her wing on the DoubleDate "Hiking in Manoa Valley"
      notifications.create(:user => engagement.wing, :push => true)
    end
  end
end
