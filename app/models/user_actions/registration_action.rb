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

class RegistrationAction < UserAction
  def coin_value
    1000
  end

  def meta_string
    "#{user} joined DBLD8 and #{cost_string}"
  end
end
