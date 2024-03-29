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
#  features              :hstore
#  locale                :string(255)
#

class User < ActiveRecord::Base
  include Concerns::FriendConcerns
  include Concerns::UUIDConcerns

  DEFAULT_BIOS = I18n.t('default_bios')

  serialize :features, ActiveRecord::Coders::Hstore

  attr_accessible :email, :password, :first_name, :last_name, :birthday,
    :single, :interested_in, :gender, :bio, :interest_ids, :location,
    :interest_names, :location_id

  attr_accessor :accessible, :approved, :sort_date

  GENDER_CHOICES = %w(male female)
  INTEREST_CHOICES = %w(guys girls both)

  before_validation :before_init, :on => :create

  after_update :trigger_update_bio_event
  after_create :after_init, :on => :create
  after_commit :send_welcome_email, :on => :create

  before_save :sanitize_bio

  # Password // Bcrypt
  has_secure_password

  scope :guys, where("gender = ?", :male)
  scope :girls, where("gender = ?", :female)
  scope :with_location, where('location_id is not null').includes(:location)

  has_many :events, :dependent => :destroy

  # Notifications
  has_many :notifications, 
    :dependent => :destroy,
    :include => [:target]

  # Purchases
  has_many :purchases,
    :dependent => :destroy,
    :include => [:coin_package]

  has_many :devices, :dependent => :destroy

  belongs_to :location, 
    :counter_cache => true

  has_and_belongs_to_many :interests

  has_one :token, :class_name => 'AuthToken', :dependent => :destroy
  
  has_one :profile_photo, :class_name => 'UserPhoto', :dependent => :destroy
  has_many :profile_photos, :class_name => 'UserPhoto', :dependent => :destroy

  # Registration validation
  validates_presence_of :first_name, :last_name, :birthday, :gender

  validates_inclusion_of :gender,
    :in => GENDER_CHOICES,
    :message => "Field user.gender is required. Possible values are #{GENDER_CHOICES.join(', ')}."

  validates_inclusion_of :interested_in, 
    :in => INTEREST_CHOICES, 
    :allow_nil => true, 
    :allow_blank => true

  validate :max_interests
  validate :old_enough, :on => :create

  has_many :activities, 
    :include => [:location, :user => [:profile_photo, :location], :wing => [:profile_photo, :location]],
    :dependent => :destroy

  has_many :participating_activities, 
    :include => [:location, :user => [:profile_photo, :location], :wing => [:profile_photo, :location]],
    :class_name => "Activity", 
    :foreign_key => "wing_id",
    :dependent => :destroy

  has_many :engagements, 
    :dependent => :destroy
  
  has_many :participating_engagements, 
    :class_name => "Engagement",
    :foreign_key => "wing_id",
    :dependent => :destroy

  has_many :engaged_activities, 
    :include => [:user, :wing, :location],
    :through => :engagements,
    :source => :activity

  has_many :engaged_participating_activities, 
    :include => [:user, :wing, :location],
    :through => :participating_engagements,
    :source => :activity

  # Messages
  has_many :message_proxies,
    :dependent => :destroy
  
  has_many :messages, 
    :through => :message_proxies

  has_many :unread_messages,
    :through => :message_proxies,
    :source => 'message',
    :conditions => {'message_proxies.unread' => true}

  # Feedback
  has_many :feedback_submissions, 
    :class_name => "Feedback",
    :dependent => :destroy

  def before_init
    self.interested_in ||= interested_in_from_gender
    
    self.features = {
      max_activities: 3
    }
  end

  def to_s
    first_name
  end

  def full_name
    [first_name, last_name].join ' '
  end

  def status
    I18n.t((single?) ? :single : :taken, :scope => :users)
  end

  def age
    @age ||= ((Date.today - birthday).to_i / 365.25).to_i
  end

  def photo
    profile_photo || DefaultUserPhoto.new(self)
  end

  def interest_names=(interest_names)
    self.interests = if interest_names.nil?
      []
    else
      interest_names.map { |n| Interest.find_or_create_by_name(n.strip) }
    end
  end

  def interests_matching_with(another_user)
    common_interests = (interests.pluck(:id) & another_user.interests.pluck(:id))
    interests.map do |interest|
      interest.tap { |n| n.matched = common_interests.include?(n.id) }
    end
  end

  def interested_in_from_gender
    case gender
    when 'male' then 'girls'
    when 'female' then 'guys'
    else 'girls'
    end
  end

  def gender_posessive
    I18n.t((gender == "male") ? :posessive_his : :posessive_her, :scope => :users)
  end

  def pronoun
    I18n.t((gender == "male") ? :pronoun_him : :pronoun_her, :scope => :users)
  end

  def activity_associations
    [:activities, :participating_activities, 
      :engaged_activities, :engaged_participating_activities]
  end

  def my_activities
    (activities + participating_activities + engaged_activities + engaged_participating_activities)
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
    0 # actions.uncached { actions.sum :karma }
  end

  def can_spend?(amount)
    (total_coins - amount.abs) > 0
  end

  def sanitize_bio
    self.bio = if self.bio.empty?
      User::DEFAULT_BIOS.sample
    else
      self.bio.gsub("\n", " ").gsub("\r", " ").squeeze(" ")[0..250]
    end
  end

  def unread_notifications_count
    notifications.events.unread.count
  end

  def unread_messages_count
    unread_messages.count
  end

  def pending_wings_count
    pending_friends.count
  end

  def badge_count
    unread_notifications_count + unread_messages_count + pending_wings_count
  end

  def logout!
    token.destroy
    devices.destroy_all
  end

  def as_json(options={})
    'BUILD'
  end

  def approved?
    approved != false
  end

  # segment.io traits
  def traits
    t = { 
      created: created_at,
      email: email,
      firstName: first_name,
      lastName: last_name,
      name: full_name,
      gender: gender,
      birthday: birthday,
    }

    if location.present?
      t[:location] = location.location_name
      t[:country] = location.country.un_locode
    end

    return t
  end

  def send_welcome_email
    UserMailer.delay.welcome_email(self)
  end

  private

  def mass_assignment_authorizer(role = :default)
    super + (accessible || [])
  end

  def after_init
    self.invite_slug = "#{created_at.to_i.to_s.reverse.chop}#{id}#{Random.rand(10)}"
    self.create_token
    save!
  end

  def max_interests
    if interests(:reload).count > 10
      errors.add(:interests, I18n.t('interests.maximum_reached'))
    end
  end

  def old_enough
    if age < 17
      errors.add(:age, I18n.t('age_limit_message', :scope => :users))
    end
  end

  def trigger_update_bio_event
    Analytics.track(user_id: uuid, event: 'User Updated Bio') if bio_changed?
  end

end
