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
    nt(nil, friend: friendship.friend)
  end

  def notification_url
    "users/#{friendship.friend.id}"
  end

  def dialog
    {
      slug: "inform",
      user_id: related.friend.id,
      coins: self.class.coin_value,
      upper_text: I18n.t('dialogs.earned_coins_text', coins: coins),
      description: I18n.t('dialogs.recruited_wing_invite', user_name: related.friend.first_name, coins: coins),
      dismiss_text: I18n.t('dialogs.close_text')
    }
  end

  def photos
    [friendship.friend.photo] if related.present?
  end

end
