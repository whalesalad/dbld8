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

class RegistrationEvent < Event
  earns 500

  def detail_string_params
    { user_name: self.user.first_name }
  end

  def notification_string_for(user)
    nt(nil, friend_name: self.user.first_name)
  end

  def notification_url
    "users/#{user.id}"
  end

  def notify
    friend_service = FacebookFriendService.new(user)
    friend_service.already_users.each do |existing_user|
      notifications.create(:user => existing_user, :push => true)
    end
  end

  def dialog
    {
      slug: "invite_user",
      user_id: user.id,
      coins: RecruitedWingEvent.coin_value,
      confirm_url: "/users/#{user.id}/invite",
      upper_text: I18n.t('dialogs.invite_user.upper_text', coins: RecruitedWingEvent.coin_value),
      description: I18n.t('dialogs.invite_user.description', friend_name: self.user.first_name),
      confirm_text: I18n.t('dialogs.invite_user.confirm_text'),
      dismiss_text: I18n.t('dialogs.invite_user.dismiss_text')
    }
  end

  def photos
    [user.photo]
  end
end
