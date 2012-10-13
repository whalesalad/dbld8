class FacebookWallPost
  @queue = :facebook_wall_posts

  def self.perform(facebook_invite_id)
    invite = FacebookInvite.find(facebook_invite_id)
    invite.send_invite()
  end
end