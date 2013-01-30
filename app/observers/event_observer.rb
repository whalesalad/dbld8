class EventObserver < ActiveRecord::Observer

  def after_commit(event)
    if event.send(:transaction_include_action?, :create)
      Rails.logger.debug("Event created #{event.id}, trying to create a notification now.")
      
      # Send notifications for this event, if the event has any
      event.notify() if event.respond_to?(:notify)

      # Track the Event
      $segmentio.track(
        user_id: event.user.uuid,
        event: event.human_name,
        properties: event.properties
      )
    end
  end

end