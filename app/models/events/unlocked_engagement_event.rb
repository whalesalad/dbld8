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
  alias engagement related

  def related_admin_path
    [:admin, engagement.activity, engagement]
  end

  def coin_value
    -50
  end

  def detail_string
    "#{user} accepted #{engagement}"
  end
end
