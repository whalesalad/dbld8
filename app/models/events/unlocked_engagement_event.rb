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

class UnlockedEngagementEvent < Event
  def coin_value
    -50
  end

  # related is an Engagement object, so let's make this easy on ourselves
  def engagement
    related
  end

  def detail_string
    "#{user} accepted #{engagement}"
  end
end
