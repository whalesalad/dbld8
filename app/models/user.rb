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
#

class User < ActiveRecord::Base
  after_create :fetch_and_store_facebook_photo

  has_secure_password

  belongs_to :location
  has_and_belongs_to_many :interests

  has_one :photo, :class_name => 'UserPhoto'

  attr_accessible :email, :password, :first_name, :last_name, :birthday, 
    :single, :interested_in, :gender, :bio, :interest_ids, :location,
    :interest_names, :location_id

  attr_accessor :accessible

  GENDER_CHOICES = %w(male female)
  INTEREST_CHOICES = %w(guys girls both)

  validates_uniqueness_of :email
  validates_presence_of :first_name, :last_name, :birthday, :gender, :email

  validates_inclusion_of :gender, :in => GENDER_CHOICES
  validates_inclusion_of :interested_in, :in => INTEREST_CHOICES

  # Handles calculating the users' age (even with leap year!)
  def age
    if birthday.present?
      now = Time.now.utc.to_date
      return now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
    end
  end

  def as_json(options={})
    exclude = [:created_at, :updated_at, :password_digest, :facebook_access_token, :location_id]
    exclude.push :id if new_record?
    result = super({ :except => exclude }.merge(options))
    
    # Add some goodies
    result[:age] = age
    
    if photo.present?
      result[:photo] = photo
    elsif facebook_user?
      result[:photo] = {
        :thumb => facebook_photo(:large)
      }
    end

    result[:interests] = interests if interests.present?
    result[:location] = location if location.present?

    result
  end

  def to_s
    "#{first_name} #{last_name}"
  end

  def facebook_user?
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
    unless self.facebook_user?
      return
    end

    graph = self.get_facebook_graph()
    me = graph.get_object('me')

    self.facebook_id = me['id']

    # This is horrible code, needs to be refactored to loop
    self.first_name = me['first_name']
    self.last_name = me['last_name']
    self.gender = me['gender']

    inverse_gender_map = { 'male' => 'girls', 'female' => 'guys' }

    self.interested_in = inverse_gender_map[self.gender]

    taken_rel_status = ['Engaged', 'Married', "It's complicated", 'In a relationship', 
                        'In a civil union', 'In a domestic partnership']

    if taken_rel_status.include? me['relationship_status']
      self.single = false
    end

    self.birthday = Date.strptime(me['birthday'],'%m/%d/%Y')

    self.email = me['email']
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
  end

  def fetch_and_store_facebook_photo
    if facebook_user? and photo.blank?
      photo = UserPhoto.new
      photo.user_id = self.id
      photo.remote_image_url = full_size_facebook_photo
      photo.save!
    end
  end

  def interest_names=(interests)
    interests.map! do |interest_name|
      Interest.find_or_create_by_name(interest_name)
    end

    self.interests = interests
  end

  private  

  def mass_assignment_authorizer(role = :default)
    super + (accessible || [])
  end 

end


