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

class RecruitAction < UserAction
  
  validates_uniqueness_of :user_id, 
    :scope => [:related_id, :related_type], 
    :message => "This user has already been awarded for this recruit."

  def meta_string
    "#{user} recruited #{related.future_user} and #{cost_string}"
  end

end
