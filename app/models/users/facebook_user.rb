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

class FacebookUser < User
  # Handles tracking facebook invitations and hooking credits where necessary
  include Concerns::FacebookInviteConcerns

  # Get the facebook photo if no profile photo exists.
  after_commit :fetch_facebook_photo, 
    :on => :create, 
    :if => Proc.new { |u| u.profile_photo.nil? }

  attr_accessor :facebook_graph, :large_facebook_photo

  validates_presence_of :facebook_id, :facebook_access_token, :on => :create

  validates_uniqueness_of :facebook_id,
    :allow_nil => true, 
    :message => "A user already exists with this facebook_id."

  def photo    
    if profile_photo.blank?
      return fetch_facebook_photo
    end
    profile_photo
  end

  def default_photo
    facebook_photo(:large)
  end

  def facebook_graph
    @facebook_graph ||= get_facebook_graph
  end

  def large_facebook_photo
    @large_facebook_photo ||= get_large_facebook_photo
  end

  def fetch_facebook_photo
    if large_facebook_photo
      p = build_profile_photo
      p.remote_image_url = large_facebook_photo
      p.save!
      p
    end
  end

  def facebook_friends
    facebook_graph.get_connections("me", "friends", { :fields => 'id,name,gender,location,picture' })
  end

  def before_validation_on_create    
    # Set the password to some crap with their facebook_id
    # no one should ever know this.
    pass = "!+%+#{facebook_id}!"
    
    self.password = pass
    self.password_confirmation = pass

    # Finally, let's bootstrap some datas
    self.bootstrap_facebook_data

    # Finally. call the user's superclass for this.
    super
  end

  def bootstrap_facebook_data
    me = facebook_graph.get_object('me')

    self.facebook_id = me['id']

    # Loop the below attributes, they map 1:1 with our own
    %w(email first_name last_name gender).each do |fb_attr|
      self[fb_attr] = me[fb_attr] if self.read_attribute(fb_attr).blank?
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

  private

  def get_facebook_graph
    require 'koala'
    Koala::Facebook::API.new facebook_access_token
  end

  def facebook_photo(size=:large)
    "https://graph.facebook.com/#{facebook_id}/picture?type=#{size}"
  end

  def get_large_facebook_photo
    q = "select src_big from photo where pid in (select cover_pid from album where owner=#{facebook_id} and name=\"Profile Pictures\")"
    result = facebook_graph.fql_query(q)
    if result.any? && result[0].has_key?('src_big')
      result[0]['src_big'] 
    end
  end

end
