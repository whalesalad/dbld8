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

class RecruitAction < UserAction
  def coin_value
    10
  end

  validates_uniqueness_of :user_id, 
    :scope => [:related_id, :related_type], 
    :message => "This user has already been awarded for this recruit."

  def invite
    related
  end

  def meta_string
    "#{user} recruited #{invite.future_user} and #{cost_string}"
  end

end
