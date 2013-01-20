namespace :dbld8 do
  task :reconstruct_events => :environment do
    puts "Reconstructing events based on current data..."

    puts "Destroying all events..."
    Event.destroy_all

    puts "Creating registration events"
    User.all.each do |user|
      RegistrationEvent.create(:user => user)
    end

    puts "Creating friendship events..."
    Friendship.all.each do |friendship|
      SentWingInviteEvent.create(:user => friendship.user, :related => friendship)
      if friendship.approved?
        AcceptedWingInviteEvent.create(:user => friendship.friend, :related => friendship)
        RecruitedWingEvent.create(:user => friendship.user, :related => friendship)
      end
    end

    puts "Creating activity events..."
    Activity.all.each do |activity|
      NewActivityEvent.create(:user => activity.user, :related => activity)
    end

    puts "Event reconstruction complete! #{Event.count} event(s) reconstructed."
  end
end