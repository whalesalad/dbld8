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

class AcceptedWingInviteEvent < Event
  alias friendship related

  earns 10
  
  def detail_string
    "#{user} accepted #{related? ? friendship.user : "a user"}'s wing invite"
  end
end
