class EventNotifyWorker
  include Sidekiq::Worker
  
  def perform(event_id)
    event = Event.find_by_id(event_id)
    
    return true if event.nil?

    event.notify() if event.respond_to?(:notify)
  end
end