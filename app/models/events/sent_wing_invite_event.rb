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

class SentWingInviteEvent < Event
  alias friendship related

  def detail_string
    "#{user} invited #{related? ? friendship.friend : "a user"}"
  end

  def notify
    # Send notification to the friend who was invited
    notifications.create(:user => friendship.friend, :push => true)
  end

  def photos
    [user.photo]
  end

  def notification_url
    "wings/#{user.id}"
  end
end
