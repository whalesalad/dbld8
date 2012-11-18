# == Schema Information
#
# Table name: user_actions
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  type         :string(255)
#  action_slug  :string(255)
#  cost         :integer
#  related_id   :integer
#  related_type :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class RegistrationAction < UserAction
  # def value
  # end
end
