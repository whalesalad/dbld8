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

class NewActivityEvent < Event
  alias activity related
  
  def coin_value
    10
  end
  
  def detail_string
    "#{user} created #{activity||"an activity"}"
  end

  def notify
    # Send notification to wing
    notifications.create(:user => activity.wing, :push => true)
  end
end
