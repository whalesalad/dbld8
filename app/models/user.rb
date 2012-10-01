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
#

class User < ActiveRecord::Base
  before_create :set_uuid
  after_create :fetch_and_store_facebook_photo
  before_validation :before_validation_on_create, :on => :create

  has_secure_password

  belongs_to :location, :counter_cache => true
  has_and_belongs_to_many :interests

  has_one :token, :class_name => 'AuthToken'
  has_one :photo, :class_name => 'UserPhoto'

  attr_accessible :email, :password, :first_name, :last_name, :birthday, 
    :single, :interested_in, :gender, :bio, :interest_ids, :location,
    :interest_names, :location_id

  attr_accessor :accessible

  GENDER_CHOICES = %w(male female)
  INTEREST_CHOICES = %w(guys girls both)

  # Registration validation
  validates_presence_of :first_name, :last_name, :birthday, :gender

  validates_presence_of :password, :email, :unless => :validate_facebook_user, :on => :create
  validates_presence_of :facebook_id, :facebook_access_token, :unless => :validate_email_user, :on => :create

  validates_uniqueness_of :email, :message => "A user already exists with this email address."
  validates_uniqueness_of :facebook_id, :allow_nil => true, :message => "A user already exists with this facebook_id."

  validates_inclusion_of :gender, :in => GENDER_CHOICES, :message => "The field user.gender is required. Possible values are #{GENDER_CHOICES.join(', ')}."
  validates_inclusion_of :interested_in, :in => INTEREST_CHOICES, :allow_nil => true, :allow_blank => true
  
  # Handle the friendship relationships (the intermediary)
  has_many :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  
  # This gets direct (you are user_id) and inverse (you are friend_id) user objects
  has_many :direct_friends, :through => :friendships, :conditions => { :'friendships.approved' => true }, :source => :friend
  has_many :inverse_friends, :through => :inverse_friendships, :conditions => { :'friendships.approved' => true }, :source => :user
   
  # Friends I have asked to be mine
  has_many :requested_friends, :through => :friendships, :conditions => { :'friendships.approved' => false }, :foreign_key => "user_id", :source => :friend
  
  # Pending friends that I need to say yes/no to
  has_many :pending_friends, :through => :inverse_friendships, :conditions => { :'friendships.approved' => false }, :foreign_key => "friend_id", :source => :user
  
  # Invite a friend if that friend is not this user and a friendship does not exist
  def invite(friend)
    return false if friend == self || find_any_friendship_with(friend)
    friendships.create(:friend_id => friend.id)
  end
  
  def invited?(friend)
    friendship = find_any_friendship_with(friend)
    return false if friendship.nil?
    friendship.friend == user
  end
  
  def approve(friend)
    friendship = find_any_friendship_with(friend)
    return false if friendship.nil? || invited?(friend)
    friendship.update_attribute(:approved, true)
  end
  
  def find_any_friendship_with(user)
    friendship = Friendship.where(:user_id => id, :friend_id => user.id).first
    if friendship.nil?
      friendship = Friendship.where(:user_id => user.id, :friend_id => id).first
    end
    friendship
  end
  
  def friends
    reload
    direct_friends + inverse_friends
  end
  
  def total_friends
    direct_friends(false).count + inverse_friends(false).count
  end
 
  def to_s
    "#{first_name} #{last_name}"
  end

  def age
    if birthday.present?
      now = Time.now.utc.to_date
      return now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
    end
  end

  def status
    single? ? "Single" : "Taken"
  end

  def as_json(options={})
    exclude = [:created_at, :updated_at, :password_digest, :facebook_access_token, :location_id]
    exclude.push :id if new_record?
    result = super({ :except => exclude }.merge(options))
    
    # Add some goodies
    unless new_record?
      result[:age] = age
    end

    if photo.present?
      result[:photo] = photo
    elsif facebook?
      result[:photo] = {
        :thumb => facebook_photo(:large)
      }
    end

    result[:interests] = interests if interests.present?
    result[:location] = location if location.present?

    result
  end

  def validate_facebook_user
    self.facebook_access_token.present? && self.facebook_id.present?
  end

  def validate_email_user
    self.email.present? && self.password.present?
  end

  def facebook?
    if new_record?
      self.facebook_access_token.present?
    else
      self.facebook_id.present?
    end
  end

  def get_facebook_graph
    require 'koala'
    Koala::Facebook::API.new facebook_access_token
  end

  def bootstrap_facebook_data
    return unless self.facebook?

    graph = get_facebook_graph
    me = graph.get_object('me')

    # Even if these fields are passed in via user POST,
    # ignore their answers becuase we need to keep 1:1 with FB
    self.facebook_id = me['id']
    self.email = me['email']

    # Loop the below attributes, they map 1:1 with our own
    %w(first_name last_name gender).each do |fb_attr|
      if self.read_attribute(fb_attr).blank?
        self[fb_attr] = me[fb_attr]
      end
    end

    if self.interested_in.blank?
      self.interested_in = default_interested_in_from_gender(self.gender)
    end

    if self.birthday.blank?
      self.birthday = Date.strptime(me['birthday'],'%m/%d/%Y')
    end

    taken_rel_status = ['Engaged', 'Married', "It's complicated", 'In a relationship', 
                        'In a civil union', 'In a domestic partnership']

    if taken_rel_status.include?(me['relationship_status'])
      self.single = false
    end

  end

  def facebook_photo(size=:large)
    "https://graph.facebook.com/#{facebook_id}/picture?type=#{size}"
  end

  def full_size_facebook_photo
    graph = get_facebook_graph
    result = graph.fql_query("select src_big from photo where pid in (select cover_pid from album where owner=#{facebook_id} and name=\"Profile Pictures\")")
    
    if result.any? and result[0].has_key? 'src_big'
      return result[0]['src_big']
    end

    false
  end

  def fetch_and_store_facebook_photo
    if facebook? and photo.blank?
      full_size_photo = full_size_facebook_photo

      if full_size_photo
        photo = UserPhoto.new
        photo.user_id = self.id
        photo.remote_image_url = full_size_facebook_photo
        photo.save!
      end
    end
  end

  def interest_names=(interest_names)
    interest_names.map! do |name|
      Interest.find_or_create_by_name(name.strip)
    end

    self.interests = interest_names
  end

  def default_interested_in_from_gender(gender)
    gender_map = { 'male' => 'girls', 'female' => 'guys' }
    gender_map[gender]
  end

  def before_validation_on_create
    # For example, if interested_in is not specified, let's set to opposite of gender.
    if interested_in.blank?
      self.interested_in = default_interested_in_from_gender(gender)
    end

    # Also, if we're a facebook user, we need to bootstrap required fields and set a random password
    if facebook?
      self.bootstrap_facebook_data
      self.password = "!+%+#{facebook_id}!"
      self.password_confirmation = "!+%+#{facebook_id}!"
    end
  end
  
  def set_uuid
    require 'uuid'
    uuid = UUID.new
    self.uuid = uuid.generate
  end
  
  def compact_uuid
    uuid.gsub /-/, ''
  end

  private

  def mass_assignment_authorizer(role = :default)
    super + (accessible || [])
  end 

end


