class FacebookInvite < ActiveRecord::Base
  after_create :send_invite

  attr_accessible :user_id, :facebook_id

  belongs_to :user

  def message_text
    "Hey! I'm inviting you to be my wingman. Let's go out and have some fun together!"
  end

  def invite_message
    "#{message_text} http://dbld8.com#{user.invite_path}"
  end

  def facebook_invite_message
    { :name => "Become my wing on DoubleDate!", :link => "http://dbld8.com#{user.invite_path}" }
  end

  def send_invite
    user_graph = user.get_facebook_graph
    user_graph.put_wall_post(message_text, facebook_invite_message, facebook_id)
  end
end
