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

class NoDatesNearbyEvent < Event
  alias activity related

  earns 50

  def detail_string_params
    { user_name: user.to_s }
  end

  def notification_string_for(user)
    nt(nil, coins: coins)
  end

  def notify
    notifications.create(:user => activity.user, :push => true)
  end

  def dialog
    {
      slug: "inform",
      coins: coins,
      upper_text: I18n.t('dialogs.earned_coins_text', coins: coins),
      description: notification_string_for(activity.user),
      dismiss_text: I18n.t('dialogs.dismiss_text')
    }
  end

end
