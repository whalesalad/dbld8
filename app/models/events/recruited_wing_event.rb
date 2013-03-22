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

  earns 50

  def detail_string
    "#{user} recruited #{related? ? friendship.friend : "a user"}"
  end

  def notify
    # Notify the user who recruited this person 
    # that their friend accepted + they earned some points!
    notifications.create(:user => user, :push => true)
  end

  def notification_string_for(user)
    "#{related.friend} accepted your wing invitation"
  end

  def notification_url
    "users/#{friendship.friend.id}"
  end

  def dialog
    {
      slug: "inform",
      user_id: related.friend.id,
      coins: self.class.coin_value,
      upper_text: "You Earned #{self.class.coin_value} Coins",
      description: "#{related.friend.first_name} accepted your wing invite and you both earned #{self.class.coin_value} coins!",
      dismiss_text: "Dismiss"
    }
  end

  def photos
    [friendship.friend.photo] if related.present?
  end

end
