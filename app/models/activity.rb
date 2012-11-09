# == Schema Information
#
# Table name: activities
#
#  id          :integer         not null, primary key
#  title       :string(255)     not null
#  details     :string(255)
#  day_pref    :string(255)
#  time_pref   :string(255)
#  location_id :integer
#  user_id     :integer         not null
#  wing_id     :integer         not null
#  status      :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Activity < ActiveRecord::Base
  before_create :set_default_values

  after_update do |activity|
    Resque.enqueue(UpdateCounts, 'Location:activities') if activity.location_id_changed?
  end

  attr_accessible :title, :details, :wing_id, :location_id, :day_pref, :time_pref

  default_scope order('created_at DESC')

  validates_presence_of :title, :details, :wing_id

  # Leave these fields blank for = "Anytime"
  DAY_PREFERENCES = %w(weekday weekend)
  TIME_PREFERENCES = %w(day night)

  belongs_to :user
  belongs_to :wing, :class_name => 'User'

  belongs_to :location, :counter_cache => true

  # Validate day preference
  validates_inclusion_of :day_pref, 
    :in => DAY_PREFERENCES, 
    :message => "The field activity.day_pref is required. Possible values are #{DAY_PREFERENCES.join(', ')}.",
    :allow_blank => true

  # Validate time preference
  validates_inclusion_of :time_pref, 
    :in => TIME_PREFERENCES, 
    :message => "The field activity.time_pref is required. Possible values are #{TIME_PREFERENCES.join(', ')}.",
    :allow_blank => true

  # states: active, expired
  # def state wat
  def set_default_values
    self.status ||= 'active'
  end

  def to_s
    title
  end

  def preference
    # Weekday / Daytime
    p = []
    
    if day_pref.present?
      p.append day_pref
    end

    if time_pref.present?
      p.append time_pref
    end

    (p.count > 0) ? p.join(" / ") : "Anytime"
  end

  def as_json(options={})
    exclude = [:created_at]

    result = super({ :except => exclude }.merge(options))

    result[:user] = user.as_json(:mini => true)
    result[:wing] = wing.as_json(:mini => true) if wing.present?
    result[:location] = location.as_json(:short => true) if location.present?
    
    result
  end
end
