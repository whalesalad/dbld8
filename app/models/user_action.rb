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
  before_validation :set_cost, :on => :create

  attr_accessible :cost, :related_id, :related_type

  attr_accessor :credit_action

  class << self
    def create_from_user_and_slug(user, slug, related=nil)
      action = "#{slug}_action".classify.constantize.new

      action.user = user
      action.related = related unless related.nil?
      action.save!
    end
  end

  belongs_to :user
  validates :user, { :presence => true }

  # Optionally, a related object
  belongs_to :related, :polymorphic => true

  def action_slug
    type.underscore.split('_')[0...-1].join('_')
  end

  def credit_action
    @credit_action ||= CreditAction.find_by_slug action_slug
  end

  private
  
  def set_cost
    self.cost = credit_action.cost
  end 

end
