# == Schema Information
#
# Table name: facebook_invites
#
#  id          :integer         not null, primary key
#  user_id     :integer
#  facebook_id :integer(8)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class FacebookInvite < ActiveRecord::Base
  attr_accessible :user_id, :facebook_id

  default_scope order('created_at DESC')

  # Queue up the sending of the invitation (writing on the wall)
  after_commit :on => :create do |invite|
    FacebookWallPostWorker.perform_async(invite.id)
  end

  belongs_to :user
  
  belongs_to :future_user, 
    :class_name => "FacebookUser", 
    :foreign_key => "facebook_id", 
    :primary_key => "facebook_id"

  # Ensure only one facebook -> user connection can exist.
  validates_uniqueness_of :facebook_id, :scope => :user_id

  def message_text
    "Hey! I'm inviting you to be my wingman. Let's go out and have some fun together!"
  end

  def path
    "http://dbld8.com/invite/#{user.invite_slug}"
  end

  def invite_message
    "#{message_text} #{path}"
  end

  def facebook_invite_message
    { :name => "Become my wing on DoubleDate!", :link => path }
  end

  def send_invite
    user.facebook_graph.put_wall_post(message_text, facebook_invite_message, facebook_id)
  end

  def fulfilled?
    future_user.present?
  end
end
