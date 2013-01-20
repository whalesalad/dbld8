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

# Send notification to [user, wing] on the Activity
#  Jenny + Vanessa are interested in "DoubleDateName"

# Send notification to the [wing] on the Engagement
#  Vanessa picked you to be her wing on the DoubleDate "Hiking in Manoa Valley"

class NewEngagementEvent < Event
  alias engagement related

  def participants
    if engagement.present?
      engagement.participant_names
    else
      "Users"
    end
  end

  def activity
    if engagement.present?
      engagement.activity
    else
      "an activity"
    end
  end

  def detail_string
    "#{participants} engaged in #{activity}"
  end
end
