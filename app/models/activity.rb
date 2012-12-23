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
  include Concerns::ParticipantConcerns

  before_create :set_default_values

  after_commit :create_user_action, :on => :create

  after_update do |activity|
    Resque.enqueue(UpdateCounts, 'Location:activities') if activity.location_id_changed?
  end

  attr_accessible :title, :details, :wing_id, 
    :location_id, :day_pref, :time_pref

  attr_accessor :age_bounds, :relationship

  default_scope order('created_at DESC')

  validates_presence_of :title, :details, :wing_id

  # Leave these fields blank for = "Anytime"
  DAY_PREFERENCES = %w(weekday weekend)
  TIME_PREFERENCES = %w(day night)

  RELATIONSHIP_CHOICES = %w(open owner wing interested accepted)
  IS_OPEN, IS_OWNER, IS_WING, IS_INTERESTED, IS_ACCEPTED = RELATIONSHIP_CHOICES

  ACTIVITY_STATUS = %w(active engaged expired)
  IS_ACTIVE, IS_ENGAGED, IS_EXPIRED = ACTIVITY_STATUS

  scope :engaged, where(:status => IS_ENGAGED)
  scope :expired, where(:status => IS_EXPIRED)
  scope :accepted, lambda { joins(:engagements).merge(Engagement.accepted) } 

  belongs_to :location, :counter_cache => true

  # ENGAGEMENTS
  has_many :engagements, :dependent => :destroy
  
  has_one :accepted_engagement,
    :class_name => "Engagement",
    :foreign_key => "activity_id", 
    :conditions => { 'status' => Engagement::IS_ACCEPTED }

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

    if params[:latitude] && params[:longitude]
      point = "#{params[:latitude]},#{params[:longitude]}"
    end

    tire.search(:load => true) do
      # Match title/details
      query { string(params[:query]) } if params[:query].present?
      
      # Handles min/max age range
      filter :range, min_age: { gte: params[:min_age] } if params[:min_age].present?
      filter :range, max_age: { lte: params[:max_age] } if params[:max_age].present?

      # Handles 'happening' = (weekday|weekend)
      filter :terms, preferences: [params[:happening]] if params[:happening].present?

      # Handles filtering by proximity to a point
      unless point.nil? || params[:distance].nil?
        filter :geo_distance, :distance => params[:distance], :point => point
      end

      # Default sorting of newest for now.
      sort = params[:sort] || 'newest'

      case sort
      when 'closest'
        sort { by '_geo_distance' => { point: point }} unless point.nil?  
      when 'newest'
        sort { by :created_at, 'desc' }
      when 'oldest'
        sort { by :created_at, 'asc' }
      end
      
    end
  end

  # states: active, expired
  # def state wat
  def set_default_values
    self.status ||= IS_ACTIVE
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

  def relationship
    @relationship || get_relationship_for
  end

  def get_relationship_for(a_user=nil)
    return IS_OPEN if a_user.nil?
    
    # IS_OWNER, IS_WING, IS_ENGAGED
    return IS_OWNER if a_user.id == user_id
    return IS_WING if a_user.id == wing_id

    # TODO, handle this for your user id or your wing's user id.
    if engagement = engagements.find_for_user_or_wing(a_user.id)
      return IS_INTERESTED if engagement.ignored?
      return IS_ACCEPTED if engagement.accepted?
    end
  end

  def update_relationship_as(a_user)
    tap do |activity|
      activity.relationship = get_relationship_for(a_user)  
    end
  end

  def engage!
    self.status = IS_ENGAGED
    self.save!
  end

  def engaged?
    status == IS_ENGAGED and accepted_engagement.present?
  end

  def expire!
    self.status = IS_EXPIRED
    self.save!
  end

  def accept_engagement!(engagement)
    # place logic here to automatically handle making an engagement the "accepted"
    # engagement for that activity. When an owner responds with their first message,
    # then we should call activity.accept_engagement(id) which will set the status
    # of the activity to engaged, and also mark the engagement as accepted.
    
    transaction do
      engagement.accept!
      engage!
    end
  end

  private

  def create_user_action
    user.trigger 'activity_create', self
  end

end
