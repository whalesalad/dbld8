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

  def detail_string
    "#{user} joined DoubleDate"
  end

  def notification_string_for(user)
    "Your Facebook friend #{self.user.first_name} just joined DoubleDate!"
  end

  def notify
    friend_service = FacebookFriendService.new(user)

    friend_service.already_users.each do |existing_user|
      notifications.create(:user => existing_user, :push => true)
    end
  end

  def photos
    [user.photo]
  end

  def notification_url
    "users/#{user.id}"
  end
end
