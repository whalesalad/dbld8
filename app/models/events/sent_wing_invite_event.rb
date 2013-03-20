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

  def notification_string_for(user)
    if friendship.approved?
      "You accepted #{friendship.user}'s wing invite! Woohoo!"
    else
      "#{friendship.user} invited you to be #{friendship.user.gender_posessive} wing"
    end
  end

  def notify
    # Send notification to the friend who was invited
    notifications.create(:user => friendship.friend, :push => true)
  end

  def photos
    [friendship.user.photo]
  end

  def notification_url
    "users/#{friendship.user.id}"
  end

  def dialog
    (friendship.approved?) ? inform_dialog : approve_dialog
  end

  def inform_dialog
    {
      slug: "inform",
      user_id: friendship.user.id,
      coins: AcceptedWingInviteEvent.coin_value,
      upper_text: "You Earned #{AcceptedWingInviteEvent.coin_value} Coins",
      description: "You earned #{AcceptedWingInviteEvent.coin_value} coins for accepting #{friendship.user}'s wing invite!",
      dismiss_text: "Dismiss"
    }
  end

  def approve_dialog
    {
      slug: "accept_invite",
      coins: RecruitedWingEvent.coin_value,
      upper_text: "Accept & Earn #{RecruitedWingEvent.coin_value} Coins",
      description: "Would you like to accept #{friendship.user}'s invitation?",
      confirm_text: "Approve",
      confirm_url: "/me/friends/#{friendship.user.id}/approve",
      dismiss_text: "Ignore"
    }
  end

end
