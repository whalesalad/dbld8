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
#

class User < ActiveRecord::Base
  # Handles friendships between users (wings)
  include Concerns::FriendConcerns

  # Handles tracking facebook invitations and hooking credits where necessary
  include Concerns::FacebookInviteConcerns

  before_validation :before_validation_on_create, :on => :create

  before_create :set_uuid

  after_create :fetch_and_store_facebook_photo
  after_create :set_invite_slug
  after_create :trigger_registration

  after_save do |user|
    # Tedious manual process for now
    Resque.enqueue(UpdateCounts, 'Location:users') if user.location_id_changed?
  end

  # Password // Bcrypt
  has_secure_password

  # Actions
  has_many :actions, :class_name => "UserAction", :dependent => :destroy

  belongs_to :location, :counter_cache => true

  has_and_belongs_to_many :interests

  has_one :token, :class_name => 'AuthToken', :dependent => :destroy
  
  has_one :profile_photo, :class_name => 'UserPhoto', :dependent => :destroy
  has_many :profile_photos, :class_name => 'UserPhoto', :dependent => :destroy

  attr_accessible :email, :password, :first_name, :last_name, :birthday,
    :single, :interested_in, :gender, :bio, :interest_ids, :location,
    :interest_names, :location_id

  attr_accessor :accessible, :facebook_graph, :total_credits

  GENDER_CHOICES = %w(male female)
  INTEREST_CHOICES = %w(guys girls both)

  # Registration validation
  validates_presence_of :first_name, :last_name, :birthday, :gender

  validates_presence_of :password, :email, :unless => :validate_facebook_user, :on => :create
  validates_presence_of :facebook_id, :facebook_access_token, :unless => :validate_email_user, :on => :create

  validates_uniqueness_of :email, :message => "A user already exists with this email address."
  validates_uniqueness_of :facebook_id, :allow_nil => true, :message => "A user already exists with this facebook_id."

  validates_inclusion_of :gender,
    :in => GENDER_CHOICES,
    :message => "The field user.gender is required. Possible values are #{GENDER_CHOICES.join(', ')}."

  validates_inclusion_of :interested_in, :in => INTEREST_CHOICES, :allow_nil => true, :allow_blank => true

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

  def default_photo
    "http://static.dbld8.com/misc/no-photo.png"
  end

  def photo
    profile_photo || { :thumb => (facebook?) ? facebook_photo(:large) : default_photo }
  end

  def validate_facebook_user
    facebook_access_token.present? && facebook_id.present?
  end

  def validate_email_user
    email.present? && password.present?
  end

  def facebook?
    facebook_access_token.present? || facebook_id.present?
  end

  def facebook_graph
    @facebook_graph ||= get_facebook_graph
  end

  def bootstrap_facebook_data
    return unless facebook?

    me = facebook_graph.get_object('me')

    self.facebook_id = me['id']

    # Loop the below attributes, they map 1:1 with our own
    %w(email first_name last_name gender).each do |fb_attr|
      self[fb_attr] = me[fb_attr] if self.read_attribute(fb_attr).blank?
    end

    if self.interested_in.blank?
      self.interested_in = interested_in_from_gender(self.gender)
    end

    if self.birthday.blank?
      self.birthday = Date.strptime(me['birthday'], '%m/%d/%Y')
    end

    taken_status = [
      'Engaged', 'Married', "It's complicated", 'In a relationship',
      'In a civil union', 'In a domestic partnership'
    ]

    self.single = !taken_status.include?(me['relationship_status'])
  end

  def facebook_photo(size=:large)
    "https://graph.facebook.com/#{facebook_id}/picture?type=#{size}"
  end

  def full_size_facebook_photo
    result = facebook_graph.fql_query("select src_big from photo where pid in (select cover_pid from album where owner=#{facebook_id} and name=\"Profile Pictures\")")

    if result.any? and result[0].has_key? 'src_big'
      return result[0]['src_big']
    end

    false
  end

  def fetch_and_store_facebook_photo
    if facebook? and profile_photo.blank?
      full_size_photo = full_size_facebook_photo

      if full_size_photo
        photo = UserPhoto.new
        photo.user_id = self.id
        photo.remote_image_url = full_size_facebook_photo
        photo.save!
      end
    end
  end

  def facebook_friends
    facebook_graph.get_connections("me", "friends", { :fields => 'id,name,gender,location,picture' })
  end

  def interest_names=(interest_names)
    self.interests = interest_names.map do |name|
      Interest.find_or_create_by_name(name.strip)
    end
  end

  def interested_in_from_gender(gender)
    case gender
    when 'male' then 'girls'
    when 'female' then 'guys'
    else 'girls'
    end
  end

  def before_validation_on_create
    # For example, if interested_in is not specified, let's set to opposite of gender.
    if interested_in.blank?
      self.interested_in = interested_in_from_gender(gender)
    end

    # Also, if we're a facebook user, we need to bootstrap required fields and set a random password
    if facebook?
      self.bootstrap_facebook_data
      self.password = "!+%+#{facebook_id}!"
      self.password_confirmation = "!+%+#{facebook_id}!"
    end
  end

  def invite_path
    "/invite/#{invite_slug}"
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

  def trigger(slug, related=nil)
    UserAction.create_from_user_and_slug(self, slug, related)
  end

  def total_credits
    actions.uncached { actions.sum :cost }
  end

  def as_json(options={})
    'BUILD'
  end

  private

  def mass_assignment_authorizer(role = :default)
    super + (accessible || [])
  end

  def set_uuid
    require 'securerandom'
    self.uuid = SecureRandom.uuid
  end

  def set_invite_slug
    reverse_epoch = created_at.to_i.to_s.reverse.chop
    self.invite_slug = "#{reverse_epoch}#{id}#{Random.rand(10)}"
    save!
  end

  def get_facebook_graph
    require 'koala'
    Koala::Facebook::API.new facebook_access_token
  end

  def trigger_registration
    self.trigger 'registration'
  end

end
