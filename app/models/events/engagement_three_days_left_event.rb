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

class EngagementThreeDaysLeftEvent < Event
  alias engagement related

  def detail_string
    "#{user}'s engagement ID:#{engagement.id} has three days remaining"
  end

  def notify
    # Create notifications for time remaining to be used by the eng controller
    engagement.all_participants.each do |participant|
      notifications.create(:user => participant, :push => false, :feed => false)
    end
  end

end
