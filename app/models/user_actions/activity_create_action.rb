# == Schema Information
#
# Table name: user_actions
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  type         :string(255)
#  cost         :integer
#  related_id   :integer
#  related_type :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class ActivityCreateAction < UserAction
  def meta_string
    "#{user} created #{related||"an activity"} and #{cost_string}"
  end
end
