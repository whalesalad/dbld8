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

  def coin_value
    # when a wing accepts your invitation, you earn 10 points
    10
  end

  def detail_string
    "#{user} recruited #{friendship.friend}"
  end

  def notify
    # Notify the user who recruited this person that they just earned points
    # notifications.create(:user => activity.wing, :push => true)
  end
end
