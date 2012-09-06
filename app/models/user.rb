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
  before_validation :bootstrap_facebook_account, :on => :create

  has_secure_password

  attr_accessible :email, :password, :facebook_id, 
    :facebook_access_token, :first_name, :last_name, :birthday, 
    :single, :interested_in, :gender, :bio

  GENDER_CHOICES = %w(male female)
  INTEREST_CHOICES = %w(guys girls both)

  validates_uniqueness_of :email
  validates_presence_of :first_name, :last_name, :birthday, :gender, :email

  validates_inclusion_of :gender, :in => GENDER_CHOICES
  validates_inclusion_of :interested_in, :in => INTEREST_CHOICES

  # Handles calculating the users' age (even with leap year!)
  def age
    now = Time.now.utc.to_date
    now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
  end

  def as_json(options={})
    exclude = [:created_at, :updated_at, :password_digest, :facebook_access_token]
    result = super({ :except => exclude }.merge(options))
    
    # Add some goodies
    result[:age] = age
    result[:photo] = nil

    result
  end

  def facebook_user?
    unless self.facebook_id.blank? or self.facebook_access_token.blank?
      return true
    end
    return false
  end

  def get_facebook_graph
    require 'koala'
    Koala::Facebook::API.new facebook_access_token
  end

  def bootstrap_facebook_account
    unless self.facebook_user?
      return
    end

    graph = self.get_facebook_graph()
    me = graph.get_object('me')

    # This is horrible code, needs to be refactored to loop
    if self.first_name.blank?
      self.first_name = me['first_name']
    end

    if self.last_name.blank?
      self.last_name = me['last_name']
    end

    if self.gender.blank?
      self.gender = me['gender']
    end

    inverse_gender_map = { 'male' => 'girls', 'female' => 'guys' }

    if self.interested_in.blank?
      self.interested_in = inverse_gender_map[self.gender]
    end

    # Unfortunately a password needs to be defined. This is a random one we can 
    # recreate programatically later on if we need to.
    self.password = "!#{self.id}+%+#{self.facebook_id}!"

    taken_rel_status = ['Engaged', 'Married', "It's complicated", 'In a relationship', 
                        'In a civil union', 'In a domestic partnership']

    if taken_rel_status.include? me['relationship_status']
      self.single = false
    end

    if self.birthday.blank?
      self.birthday = Date.strptime(me['birthday'],'%m/%d/%Y')
    end

    if self.email.blank?
      self.email = me['email']
    end
  end
end


