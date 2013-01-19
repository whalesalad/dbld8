# == Schema Information
#
# Table name: events
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

class Event < ActiveRecord::Base
  before_validation :set_initial_values, :on => :create

  # validate the user has enough coins in the bank
  # to do this new event

  attr_accessible :related_id, :related_type

  belongs_to :user
  validates_presence_of :user

  # Optionally, a related object
  belongs_to :related, :polymorphic => true

  def self.create_from_user_and_slug(user, slug, related=nil)
    event = self.from_slug(slug)
    event.user = user
    event.related = related unless related.nil?
    event.save!
  end

  def self.from_slug(slug)
    "#{slug}_event".classify.constantize.new
  end

  def set_initial_values
    self.coins ||= coin_value
    self.karma ||= karma_value
  end

  def to_s
    return type if type == 'Event'
    type.gsub('Event', '')
  end

  def slug
    to_s.underscore
  end

  def earns?
    coins > 0
  end

  def spends?
    !!earns?
  end

  def free?
    coin_value.nil? || coin_value == 0
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

  def detail
    s = [detail_string]
    s << cost_string unless free?
    "#{s.join(' ')}."
  end

  def cost_string
    "#{cost_verb} #{coins} coins"
  end

  def reset_initial_values!
    self.coins = coin_value
    self.karma = karma_value
    save!
  end

  def coin_value
    10
  end

  def karma_value
    0
  end

end
