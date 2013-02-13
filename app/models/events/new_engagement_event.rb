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

  def coin_value
    10
  end

  def participants
    if engagement.present?
      engagement.participant_names
    else
      "Users"
    end
  end

  def activity
    if engagement.present?
      engagement.activity
    else
      "an activity"
    end
  end

  def notification_string_for(user)
    if user == engagement.wing
      return "#{engagement.user} picked you to be #{engagement.user.gender_posessive} wing on the DoubleDate \"#{related.activity}\""
    end

    if engagement.activity.participant_ids.include?(user.id)
      return "#{engagement.participant_names} are interested in \"#{engagement.activity}\""
    end
  end

  def detail_string
    "#{participants} engaged in #{activity}"
  end

  def notify
    # Send notification to [user, wing] on the Activity
    # Jenny + Vanessa are interested in "DoubleDateName"
    engagement.activity.participants.each do |u|
      notifications.create(:user => u, :push => true)
    end

    # Send notification to the [wing] on the Engagement
    # Vanessa picked you to be her wing on the DoubleDate "Hiking in Manoa Valley"
    notifications.create(:user => engagement.wing, :push => true)
  end
end
