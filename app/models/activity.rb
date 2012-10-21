class Activity < ActiveRecord::Base
  attr_accessible :title, :details, :location_id, :day_pref, :time_pref

  validates_presence_of :title, :details

  # Leave these fields blank for = "Anytime"
  DAY_PREFERENCES = %w(Weekday Weekend)
  TIME_PREFERENCES = %w(Daytime Nighttime)

  has_one :user, :dependent => :destroy
  has_one :wing

  # Validate day preference
  validates_inclusion_of :day_pref, 
    :in => DAY_PREFERENCES, 
    :message => "The field activity.day_pref is required. Possible values are #{DAY_PREFERENCES.join(', ')}."

  # Validate time preference
  validates_inclusion_of :time_pref, 
    :in => TIME_PREFERENCES, 
    :message => "The field activity.time_pref is required. Possible values are #{TIME_PREFERENCES.join(', ')}."

  # states: active, expired
  # def state wat

  def to_s
    title
  end
end
