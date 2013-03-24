class NoDatesNearbyWorker
  include Sidekiq::Worker
  
  def perform(activity_id)
    activity = Activity.find(activity_id)
    
    # If there aren't any nearby, give the user some extra goodies
    if activity.nearby.empty?
      NoDatesNearbyEvent.create(:user => activity.user, :related => activity)   
    end
  end
end