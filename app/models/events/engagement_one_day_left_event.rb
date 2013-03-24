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

class EngagementOneDayLeftEvent < Event
  alias engagement related

  def detail_string
    "#{user}'s engagement ID:#{(engagement.present?) ? engagement.id : 'nil'} has one day remaining"
  end

  def notification_string_for(user)
    # All four participants should receive a push notification saying the chat has expired
    if engagement.activity.participant_ids.include?(user.id)
      # Activity User + Wing
      "Your chat with #{engagement.participant_names} for #{engagement.activity} has 24 hours remaining."
    else
      # Engagement User + Wing
      "Your chat with #{engagement.activity.participant_names} for #{engagement.activity} has 24 hours remaining."
    end
  end

  def notify
    # All four participants should receive a push notification saying the chat has expired
    engagement.all_participants.each do |participant|
      notifications.create(:user => participant, :push => true)
    end
  end
  
end
