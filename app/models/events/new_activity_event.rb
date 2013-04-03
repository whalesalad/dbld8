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
  
  def detail_string_params
    {
      user_name: user,
      activity: related_to_s(Activity)
    }
  end

  def notification_string_for(user)
    if user == activity.wing
      nt(nil,
        activity_creator_name: activity.user.first_name,
        his_or_her: activity.user.gender_posessive,
        activity_title: activity.to_s
      )
    end
  end

  def notify
    # Send notification to wing
    notifications.create(:user => activity.wing, :push => true)
  end
end
