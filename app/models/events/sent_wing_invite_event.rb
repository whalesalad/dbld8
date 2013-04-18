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
      nt(:approved, user_name: friendship.user.first_name)
    else
      nt(:invited, user_name: friendship.user.first_name, his_or_her: friendship.user.gender_posessive)
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
    coins = AcceptedWingInviteEvent.coin_value
    {
      slug: "inform",
      user_id: friendship.user.id,
      coins: coins,
      upper_text: I18n.t('dialogs.accepted_wing_invite.upper_text', coins: coins),
      description: I18n.t('dialogs.accepted_wing_invite.description', coins: coins, user_name: friendship.user),
      dismiss_text: I18n.t('dialogs.close_text')
    }
  end

  def approve_dialog
    coins = RecruitedWingEvent.coin_value
    {
      slug: "accept_invite",
      coins: coins,
      confirm_url: "/me/friends/#{friendship.user.id}/approve",
      upper_text: I18n.t('dialogs.accept_invite.upper_text', coins: coins),
      description: I18n.t('dialogs.accept_invite.description', user_name: friendship.user),
      confirm_text: I18n.t('dialogs.approve_text'),
      dismiss_text: I18n.t('dialogs.close_text')
    }
  end

end
