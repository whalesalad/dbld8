class FacebookUser < User
  # Handles tracking facebook invitations and hooking credits where necessary
  include Concerns::FacebookInviteConcerns

  after_create :fetch_and_store_facebook_photo

  attr_accessible :facebook_graph

  validates_presence_of :facebook_id, :facebook_access_token, :on => :create

  validates_uniqueness_of :facebook_id, 
    :allow_nil => true, 
    :message => "A user already exists with this facebook_id."

  def default_photo
    facebook_photo(:large)
  end

  def facebook_graph
    @facebook_graph ||= get_facebook_graph
  end

  def fetch_and_store_facebook_photo
    if profile_photo.blank?
      if full_size_photo = full_size_facebook_photo
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

  private

  def before_validation_on_create    
    # Set the password to some crap with their facebook_id
    # no one should ever know this.
    pass = "!+%+#{facebook_id}!"
    
    self.password = pass
    self.password_confirmation = pass

    # Finally, let's bootstrap some datas
    bootstrap_facebook_data

    # Finally. call the user's superclass for this.
    super
  end

  def get_facebook_graph
    require 'koala'
    Koala::Facebook::API.new facebook_access_token
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

  def facebook_photo(size=:large)
    "https://graph.facebook.com/#{facebook_id}/picture?type=#{size}"
  end

  def full_size_facebook_photo
    q = "select src_big from photo where pid in (select cover_pid from album where owner=#{facebook_id} and name=\"Profile Pictures\")"
    result = facebook_graph.fql_query(q)

    if result.any? and result[0].has_key? 'src_big'
      return result[0]['src_big']
    end

    false
  end

end