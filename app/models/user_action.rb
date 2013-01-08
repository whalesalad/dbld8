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

class UserAction < ActiveRecord::Base
  before_validation :determine_initial_values, :on => :create

  attr_accessible :related_id, :related_type

  class << self
    def create_from_user_and_slug(user, slug, related=nil)
      action = "#{slug}_action".classify.constantize.new
      action.user = user
      action.related = related unless related.nil?
      action.save!
    end
  end

  belongs_to :user
  validates_presence_of :user

  # Optionally, a related object
  belongs_to :related, :polymorphic => true

  def to_s
    type.gsub('Action', '')
  end

  def earns?
    coins > 0
  end

  def spends?
    !!earns?
  end

  def cost_verb
    earns? ? "earned" : "spent"
  end

  def prefix
    earns? ? '+' : '-'
  end

  def cost_to_s
    "#{prefix}#{coins.abs}"
  end

  def meta_string
    "undefined"
  end

  def cost_string
    "#{cost_verb} #{coins} coins."
  end

  def action_slug
    to_s.underscore
  end

  private

  def current_coin_value
    10
  end

  def current_karma_value
    0
  end

  def determine_initial_values
    self.coins ||= coin_value
    self.karma ||= karma_value
  end

end
