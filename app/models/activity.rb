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
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Activity < ActiveRecord::Base
  DAY_PREFERENCES = %w(weekday weekend)
  TIME_PREFERENCES = %w(day night)
  SEARCH_RADIUS = "200km"
  RELATIONSHIP_CHOICES = %w(open owner wing engaged)
  IS_OPEN, IS_OWNER, IS_WING, IS_ENGAGED = RELATIONSHIP_CHOICES

  include Concerns::ParticipantConcerns
  include Concerns::EventConcerns

  attr_accessor :age_bounds, :relationship, :engagement, :interests

  attr_accessible :title, :details, :wing_id, 
    :location_id, :day_pref, :time_pref

  validates_presence_of :title, :details, :wing_id, :location_id

  default_scope order('updated_at DESC')

  scope :with_engagements, joins(:engagements).group('activities.id').having('COUNT(engagements.id) > 0')
  
  scope :for_user, lambda {|user|
    select('distinct(activities.id)').includes(:engagements).where('activities.user_id = ? OR activities.wing_id = ? OR engagements.user_id = ? OR engagements.wing_id = ?', user.id, user.id, user.id, user.id)
  }

  scope :for_user_with_engagements, lambda {|user|
    joins(:engagements).where('activities.user_id = ? OR activities.wing_id = ? OR engagements.user_id = ? OR engagements.wing_id = ?', user.id, user.id, user.id, user.id)
  }

  # Location
  belongs_to :location, :counter_cache => true

  # Engagements
  has_many :engagements, 
    :dependent => :destroy,
    :include => [:user, :wing]

  # Messages
  has_many :messages, :through => :engagements

  # Validate day preference
  validates_inclusion_of :day_pref, 
    :in => DAY_PREFERENCES, 
    :message => "Possible values for day_pref are #{DAY_PREFERENCES.join(', ')}.",
    :allow_blank => true

  # Validate time preference
  validates_inclusion_of :time_pref, 
    :in => TIME_PREFERENCES, 
    :message => "Possible values for time_pref are #{TIME_PREFERENCES.join(', ')}.",
    :allow_blank => true

  # Tire // Elasticsearch
  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id, :index => :not_analyzed
    indexes :title, :analyzer => 'snowball', :boost => 100
    indexes :point, :type => 'geo_point', :as => 'location.elasticsearch_point', :boost => 40
    indexes :details, :analyzer => 'snowball'
    indexes :location, :analyzer => 'snowball', :as => 'location.name'
    indexes :preferences, :as => 'day_time_preferences', :index_name => :preference
    indexes :created_at, :type => 'date'
    indexes :min_age, :type => 'integer', :as => 'age_bounds.first'
    indexes :max_age, :type => 'integer', :as => 'age_bounds.last'
    indexes :tags, :type => 'string', :analyzer => 'keyword', :as => 'interest_names'
  end

  def self.search(params, user)
    Rails.logger.debug("Tire: #{params.inspect}")

    # If we specify anytime, ignore it to include everything
    params.delete :happening if !!(params[:happening] =~ /anytime/i)

    tire.search(:load => { :include => [:location, {:user => [:profile_photo, :location]}, {:wing => [:profile_photo, :location]}] }, :per_page => 30) do
      # Match title/details
      query { string(params[:query]) } if params[:query].present?

      # Handles min/max age range
      filter :range, min_age: { gte: params[:min_age] } if params[:min_age].present?
      filter :range, max_age: { lte: params[:max_age] } if params[:max_age].present?

      # Handles 'happening' = (weekday|weekend)
      filter :terms, preferences: [params[:happening]] if params[:happening].present?

      # Limit our results to the search radius
      filter :geo_distance, :distance => SEARCH_RADIUS, :point => params[:point]

      # Sort by proximity to the point
      sort { by '_geo_distance' => { point: params[:point] }}
    end
  end

  def to_s
    title
  end

  def preference
    day_time_preferences.map{ |p| p.capitalize }.join " + "
  end

  def day_time_preferences
    prefs = [day_pref, time_pref]
    (prefs.any?) ? prefs.compact : ['anytime']
  end

  def age_bounds
    @age_bounds ||= [user.age, wing.age].sort!
  end

  def interests
    @interests ||= (user.interests + wing.interests).uniq
  end

  def interest_names
    interests.collect { |i| i.name }
  end

  def allowed?(a_user, permission = :all)
    case permission
    when :owner, :modify
      a_user == user
    when :all, :owners
      participant_ids.include? a_user.id
    end
  end

  def relationship(a_user=nil)
    @relationship ||= get_relationship_for(a_user)
  end

  def engagement(a_user=nil)
    @engagement ||= engagements.find_for_user_or_wing(a_user.id).first
  end

  def get_relationship_for(a_user=nil)
    unless a_user.nil?
      # IS_OWNER, IS_WING, IS_ENGAGED
      return IS_OWNER if a_user.id == user_id
      return IS_WING if a_user.id == wing_id

      # If you or your wing have an engagement, your'e engaged.
      # if engagements.find_for_user_or_wing(a_user.id).exists?
      if engagement(a_user).present?
        return IS_ENGAGED
      end
    end

    IS_OPEN
  end

  def update_relationship_as(a_user)
    tap { |a| a.relationship = a.get_relationship_for(a_user) }
  end

end
