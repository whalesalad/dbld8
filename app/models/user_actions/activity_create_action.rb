# == Schema Information
#
# Table name: user_actions
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

class ActivityCreateAction < UserAction
  def coin_value
    10
  end

  def activity
    related
  end
  
  def meta_string
    "#{user} created #{activity||"an activity"} and #{cost_string}"
  end
end
