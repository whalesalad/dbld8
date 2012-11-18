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

class UserAction < ActiveRecord::Base
  attr_accessible :action_slug, :cost, :related_id, :related_type

  belongs_to :user

  validates :user, { :presence => true }

  belongs_to :action,
    :class_name => "CreditAction",
    :foreign_key => :action_slug,
    :primary_key => :slug

  validates :action, { :presence => true }

  # Optional related object
  belongs_to :related, :polymorphic => true

end
