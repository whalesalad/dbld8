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

  spends 50

  def detail_string
    "#{user} unlocked an engagement from #{engagement||'a deleted engagement'}"
  end
end
