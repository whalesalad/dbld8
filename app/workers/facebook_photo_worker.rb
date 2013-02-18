class FacebookPhotoWorker
  include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find_by_id(user_id)
    user.fetch_facebook_photo unless user.nil?
  end
end