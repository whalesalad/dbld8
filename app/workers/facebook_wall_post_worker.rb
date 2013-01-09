class FacebookWallPostWorker
  include Sidekiq::Worker
  
  def perform(facebook_invite_id)
    invite = FacebookInvite.find(facebook_invite_id)
    invite.send_invite()
  end
end