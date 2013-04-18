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

class EngagementExpiredEvent < Event
  alias engagement related

  def detail_string_params
    {
      user_name: user,
      engagement: related_to_s(Engagement)
    }
  end

  def notification_string_for(user)
    # All four participants should receive a push notification saying the chat has expired
    params = {
      activity: engagement.activity.to_s
    }
    
    params[:users] = if engagement.activity.participant_ids.include?(user.id)
      engagement.participant_names
    else
      engagement.activity.participant_names
    end

    nt(nil, params)
  end

  def notify
    # All four participants should receive a push notification saying the chat has expired
    engagement.all_participants.each do |participant|
      notifications.create(:user => participant, :push => true)
    end
  end

end
