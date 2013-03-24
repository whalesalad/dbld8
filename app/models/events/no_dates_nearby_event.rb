class NoDatesNearbyEvent < Event
  alias activity related

  earns 50

  def detail_string
    "#{user} posted a DoubleDate in an empty area"
  end

  def notification_string_for(user)
    "You earned #{coins} coins for posting a DoubleDate in an empty area!"
  end

  def notify
    notifications.create(:user => activity.user, :push => true)
  end

  def dialog
    {
      slug: "inform",
      coins: coins,
      upper_text: "You Earned #{coins} Coins",
      description: notification_string_for(activity.user),
      dismiss_text: "Dismiss"
    }
  end

end
