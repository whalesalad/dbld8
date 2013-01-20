# == Schema Information
#
# Table name: users
#
#  id                    :integer         not null, primary key
#  email                 :string(255)
#  password_digest       :string(255)
#  facebook_id           :integer(8)
#  facebook_access_token :string(255)
#  first_name            :string(255)
#  last_name             :string(255)
#  birthday              :date
#  single                :boolean         default(TRUE)
#  interested_in         :string(255)
#  gender                :string(255)
#  bio                   :text
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  location_id           :integer
#  uuid                  :uuid            not null
#  invite_slug           :string(255)
#  type                  :string(255)
#

class User < ActiveRecord::Base
  # Handles friendships between users (wings)
  include Concerns::FriendConcerns
  include Concerns::UUIDConcerns

  before_validation :on_init, :on => :create

  after_create :set_invite_slug

  # Password // Bcrypt
  has_secure_password

  has_many :events, :dependent => :nullify

  # Notifications
  has_many :notifications, :dependent => :destroy

  belongs_to :location, :counter_cache => true

  has_and_belongs_to_many :interests

  has_one :token, :class_name => 'AuthToken', :dependent => :destroy
  
  has_one :profile_photo, :class_name => 'UserPhoto', :dependent => :destroy
  has_many :profile_photos, :class_name => 'UserPhoto', :dependent => :destroy

  attr_accessible :email, :password, :first_name, :last_name, :birthday,
    :single, :interested_in, :gender, :bio, :interest_ids, :location,
    :interest_names, :location_id

  attr_accessor :accessible, :approved

  GENDER_CHOICES = %w(male female)
  INTEREST_CHOICES = %w(guys girls both)

  # Registration validation
  validates_presence_of :first_name, :last_name, :birthday, :gender

  validates_uniqueness_of :email, :message => "A user already exists with this email address."

  validates_inclusion_of :gender,
    :in => GENDER_CHOICES,
    :message => "Field user.gender is required. Possible values are #{GENDER_CHOICES.join(', ')}."

  validates_inclusion_of :interested_in, 
    :in => INTEREST_CHOICES, 
    :allow_nil => true, 
    :allow_blank => true

  has_many :activities, :dependent => :destroy
  has_many :participating_activities, 
    :class_name => "Activity", 
    :foreign_key => "wing_id"

  has_many :engagements, :dependent => :destroy
  has_many :participating_engagements, 
    :class_name => "Engagement",
    :foreign_key => "wing_id"

  has_many :engaged_activities, 
    :through => :engagements,
    :source => :activity

  has_many :engaged_participating_activities, 
    :through => :participating_engagements,
    :source => :activity


  default_scope includes(:location, :profile_photo)

  def on_init
    self.interested_in ||= interested_in_from_gender(gender)
  end
  
  def to_s
    [first_name, last_name].join ' '
  end

  def full_name
    to_s
  end

  def status
    single? ? "Single" : "Taken"
  end

  def age
    @age ||= ((Date.today - birthday).to_i / 365.25).to_i
  end

  def photo
    profile_photo || DefaultUserPhoto.new(self)
  end

  def interest_names=(interest_names)
    self.interests = interest_names.map do |name|
      Interest.find_or_create_by_name(name.strip)
    end
  end

  def interests_matching_with(another_user)
    common_interests = (interests.pluck(:id) & another_user.interests.pluck(:id))
    interests.map do |interest|
      interest.tap { |n| n.matched = common_interests.include?(n.id) }
    end
  end

  def interested_in_from_gender(gender)
    case gender
    when 'male' then 'girls'
    when 'female' then 'guys'
    else 'girls'
    end
  end

  def gender_posessive
    (gender == "male") ? "his" : "her"
  end

  def activity_associations
    [:activities, :participating_activities, 
      :engaged_activities, :engaged_participating_activities]
  end

  def my_activities
    mine = []
    activity_associations.each do |association|
      self.send(association).each { |a| mine << a.update_relationship_as(self) }
    end
    mine
  end

  def my_activities_count
    # reload
    activity_associations.map { |q| self.send(q, false).count }.inject :+
  end

  def all_engagements
    # reload
    engagements + participating_engagements
  end

  def total_coins
    events.uncached { events.sum :coins }
  end

  def total_karma
    0
    # actions.uncached { actions.sum :karma }
  end

  def can_spend?(amount)
    return (total_coins - amount.abs) > 0
  end

  def as_json(options={})
    'BUILD'
  end

  def trigger(slug, related=nil)
    UserAction.create_from_user_and_slug(self, slug, related)
  end

  private

  def mass_assignment_authorizer(role = :default)
    super + (accessible || [])
  end

  def set_invite_slug
    self.invite_slug = "#{created_at.to_i.to_s.reverse.chop}#{id}#{Random.rand(10)}"
    save!
  end

end
