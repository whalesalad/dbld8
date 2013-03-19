class FacebookSyncWorker
  include Sidekiq::Worker
  
  def perform(user_id)
    # Get user
    @user = User.find(user_id)

    # Get graph
    @graph = @user.facebook_graph.get_object('me')

    # Perform sync
    @user.sync_facebook_data(@graph)

    # Save user
    @user.save!
  end
end