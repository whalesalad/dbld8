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
      upper_text: "You Earned #{coins} Coins",
      description: notification_string_for(activity.user),
      dismiss_text: "Dismiss"
    }
  end

end
