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
  include Concerns::ParticipantConcerns
  include Concerns::EventConcerns

  attr_accessor :age_bounds, :relationship

  attr_accessible :title, :details, :wing_id, 
    :location_id, :day_pref, :time_pref

  validates_presence_of :title, :details, :wing_id, :location_id

  default_scope order('activities.updated_at DESC')

  scope :with_engagements, joins(:engagements).group('activities.id').having('COUNT(engagements.id) > 0')
  
  scope :for_user, lambda {|user|
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

  DAY_PREFERENCES = %w(weekday weekend)
  TIME_PREFERENCES = %w(day night)

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

  RELATIONSHIP_CHOICES = %w(open owner wing engaged)
  IS_OPEN, IS_OWNER, IS_WING, IS_ENGAGED = RELATIONSHIP_CHOICES

  # Tire // Elasticsearch
  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id, :index => :not_analyzed
    indexes :title, :analyzer => 'snowball', :boost => 100
    indexes :details, :analyzer => 'snowball'
    indexes :location, :analyzer => 'snowball', :as => 'location.name'
    indexes :preferences, :as => 'day_time_preferences', :index_name => :preference
    indexes :created_at, :type => 'date'
    indexes :point, :type => 'geo_point', :as => 'location.elasticsearch_point'
    indexes :min_age, :type => 'integer', :as => 'age_bounds.first'
    indexes :max_age, :type => 'integer', :as => 'age_bounds.last'
  end

  def self.search(params)
    # If we specify anytime, ignore it to include everything
    params.delete :happening if !!(params[:happening] =~ /anytime/i)

    tire.search(:load => { :include => [:user, :wing, :location] }, :per_page => 30) do
      # Match title/details
      query { string(params[:query]) } if params[:query].present?
      
      # Handles min/max age range
      filter :range, min_age: { gte: params[:min_age] } if params[:min_age].present?
      filter :range, max_age: { lte: params[:max_age] } if params[:max_age].present?

      # Handles 'happening' = (weekday|weekend)
      filter :terms, preferences: [params[:happening]] if params[:happening].present?

      # Handles filtering by proximity to a point
      unless params[:point].nil? || params[:distance].nil?
        filter :geo_distance, :distance => params[:distance], :point => params[:point]
      end

      # Default sorting of newest for now.
      sort = params[:sort] || 'newest'

      case sort
      when 'closest'
        sort { by '_geo_distance' => { point: params[:point] }} unless params[:point].nil?  
      when 'newest'
        sort { by :created_at, 'desc' }
      when 'oldest'
        sort { by :created_at, 'asc' }
      end

      Rails.logger.debug("Tire: #{params.inspect}")
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

  def get_relationship_for(a_user=nil)
    unless a_user.nil?
      # IS_OWNER, IS_WING, IS_ENGAGED
      return IS_OWNER if a_user.id == user_id
      return IS_WING if a_user.id == wing_id

      # If you or your wing have an engagement, your'e engaged.
      if engagements.find_for_user_or_wing(a_user.id).exists?
        return IS_ENGAGED
      end
    end

    IS_OPEN
  end

  def update_relationship_as(a_user)
    tap { |a| a.relationship = a.get_relationship_for(a_user) }
  end

end
