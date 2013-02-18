class FacebookInterestsWorker
  include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find(user_id)
    
    interests = user.facebook_graph.get_object('/me/interests')
    activities = user.facebook_graph.get_object('/me/activities')

    ids = (interests + activities).collect { |a| a['id'] }.uniq

    combined_interests = user.facebook_graph.get_objects(ids)

    combined_interests = combined_interests.sort_by { |id, interest| -interest['likes'] }

    user.interest_names = combined_interests.first(10).collect { |id, interest| interest['name'] }

    user.save!
  end
end