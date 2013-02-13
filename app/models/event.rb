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
  attr_accessible :user, :related

  before_validation :set_initial_values, :on => :create

  belongs_to :user
  validates_presence_of :user

  default_scope order('created_at DESC')
  
  # ERRORING OUT
  # validate :has_enough_coins, :on => :create

  has_many :notifications, 
    :as => :target,
    :dependent => :destroy

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

  def self.clean_notifications
    self.all.each do |e|
      e.notifications.destroy_all if e.related.nil?
    end
  end

  def has_enough_coins
    unless user.can_spend?(coin_value)
      errors.add(:user, "does not have enough coins to perform this event.")
    end
  end

  def set_initial_values
    self.coins ||= coin_value
    self.karma ||= karma_value
  end

  def to_s
    self.class.model_name.gsub('Event', '')
  end

  def human_name
    to_s.titleize
  end

  def slug
    to_s.underscore
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
    self.coins = coin_value
    self.karma = karma_value
    save!
  end

  def coin_value
    0
  end

  def karma_value
    0
  end

  def photos
    related.photos if related?
  end

  def notification_url
    if related?
      related.notification_url
    else
      super
    end
  end

  def app_identifier
    return related.app_identifier if related?
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
