task :initialize_credits => :environment do
  
  User.all.each do |user|
    # Give all users registration actions.
    user.trigger 'registration'

    # Give all users activity_create actions for activities they own
    user.activities.each do |activity|
      user.trigger 'activity_create', activity
    end
  end

end