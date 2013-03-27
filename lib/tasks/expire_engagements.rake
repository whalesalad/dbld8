namespace :dbld8 do
  task :expire_engagements => :environment do
    @events = []

    @one_day_remaining = Engagement.not_ignored.one_day_left
    @to_expire = Engagement.not_ignored.to_be_expired

    log "Processing engagements with one day remaining..."
    @one_day_remaining.each do |engagement|
      @events << EngagementOneDayLeftEvent.create(:user => engagement.user, :related => engagement)
    end
    log "  #{@one_day_remaining.count} engagement(s) processed."


    log "Expiring engagements that have no time remaining..."    
    @to_expire.each do |engagement|
      @events << EngagementExpiredEvent.create(:user => engagement.user, :related => engagement)
    end
    log "  #{@to_expire.count} engagement(s) expired."


    log "================================================"
    log "#{@events.size} events were created. Finished processing."
  end

  def log(msg)
    puts "[ ENGAGEMENT EXPIRATION ] #{msg}"
  end
end