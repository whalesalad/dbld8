namespace :dbld8 do
  task :expire_engagements => :environment do
    @events = []

    log "Processing engagements with three days remaining..."
    Engagement.three_days_left.each do |engagement|
      @events << EngagementThreeDaysLeftEvent.create(:user => engagement.user, :related => engagement)
    end
    log "  #{Engagement.three_days_left.count} engagement(s) processed."

    log "Processing engagements with one day remaining..."
    Engagement.one_day_left.each do |engagement|
      @events << EngagementOneDayLeftEvent.create(:user => engagement.user, :related => engagement)
    end
    log "  #{Engagement.one_day_left.count} engagement(s) processed."

    log "Expiring engagements that have no time remaining..."    
    Engagement.to_be_expired.each do |engagement|
      @events << EngagementExpiredEvent.create(:user => engagement.user, :related => engagement)
    end
    log "  #{Engagement.to_be_expired.count} engagement(s) expired."

    log "================================================"

    log "#{@events.size} events were created. Finished processing."
  end

  def log(msg)
    puts "[ ENGAGEMENT EXPIRATION ] #{msg}"
  end
end