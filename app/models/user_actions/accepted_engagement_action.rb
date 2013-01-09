# == Schema Information
#
# Table name: user_actions
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  type         :string(255)
#  coin_value   :integer
#  related_id   :integer
#  related_type :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  karma_value  :integer         default(0)
#

class AcceptedEngagementAction < UserAction
  def coin_value
    -50
  end

  # related is an Engagement object, so let's make this easy on ourselves
  def engagement
    related
  end

  def meta_string
    "#{user} accepted #{engagement} and #{cost_string}"
  end

end
