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
  class << self
    attr_accessor :coin_value
  end

  attr_accessible :user, :related

  belongs_to :user
  validates_presence_of :user

  default_scope order('created_at DESC')
  
  validate :has_enough_coins, :on => :create

  has_many :notifications, 
    :as => :target,
    :dependent => :destroy

  belongs_to :related, :polymorphic => true

  def self.earns(value)
    self.coin_value = value
  end

  def self.spends(value)
    self.coin_value = -value
  end

  after_initialize :set_initial_values

  def self.create_from_user_and_slug(user, slug, related=nil)
    event = self.from_slug(slug).new
    event.user = user
    event.related = related unless related.nil?
    event.save!
  end

  def self.from_slug(slug)
    "#{slug}_event".classify.constantize
  end

  def self.clean_notifications
    self.all.each do |e|
      e.notifications.destroy_all if e.related.nil?
    end
  end

  def has_enough_coins
    return if earns?
    
    unless user.can_spend?(self.coins)
      errors.add(:user, "does not have enough coins to perform this event.")
    end
  end

  def set_initial_values
    self.coins ||= (self.class.coin_value || 0)
    self.karma ||= (self.class.karma_value || 0)
  end

  def self.slug
    self.model_name.gsub('Event', '').underscore
  end

  def to_s
    self.class.model_name.gsub('Event', '')
  end

  def human_name
    to_s.titleize
  end

  def slug
    self.class.slug
  end

  def related?
    related.present?
  end

  def earns?
    coins >= 0
  end

  def spends?
    !earns?
  end

  def free?
    coins.nil? || coins == 0
  end

  def cost_verb
    earns? ? "earned" : "spent"
  end

  def prefix
    return '' if free?
    earns? ? '+' : '-'
  end

  def cost_to_s
    "#{prefix}#{coins.abs}"
  end

  def detail
    s = [detail_string]
    s << "and #{cost_string}" unless free?
    "#{s.join(' ')}."
  end

  def cost_string
    "#{cost_verb} #{coins.abs} coins"
  end

  def related_admin_path
    [:admin, related]
  end

  def reset_initial_values!
    self.coins = self.class.coin_value
    self.karma = self.class.karma_value
    save!
  end

  def karma_value
    0
  end

  def photos
    related.photos if related?
  end

  def notification_url
    return related.notification_url if related?
    super
  end

  def properties
    properties = { cost: cost_to_s, slug: slug }
    
    if related?
      properties[:related] = related.class.model_name
      properties[:related_id] = related.id
    end
    
    return properties
  end

end
