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

  def coin_value
    10 # when you accept a friendship, you earn 10 points
  end

  def detail_string
    "#{user} accepted #{friendship.user||"someone"}'s wing invite"
  end
end
