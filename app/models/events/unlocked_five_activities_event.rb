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

class UnlockedFiveActivitiesEvent < Event
  spends 50

  def self.json
    {
      slug: slug,
      cost: coin_value,
      max_activities: 5,
      title: "Unlock 5 Dates",
      description: "Unlock the ability to post 5 DoubleDates at a time?"
    }
  end

  def detail_string
    "#{user} unlocked the ability to post 5 dates at a time"
  end
end
