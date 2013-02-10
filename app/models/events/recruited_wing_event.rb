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

class RecruitedWingEvent < Event
  alias friendship related

  def coin_value
    10 # when a wing accepts your invitation, you earn 10 points
  end

  def detail_string
    "#{user} recruited #{related? ? friendship.friend : "a user"}"
  end

  def notify
    # Notify the user who recruited this person 
    # that their friend accepted + they earned some points!
    notifications.create(:user => user, :push => true)
  end

  def photos
    [friendship.friend.photo] if related.present?
  end

  def notification_url
    "wings/#{friendship.friend.id}"
  end
end
