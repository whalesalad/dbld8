class MessageObserver < ActiveRecord::Observer
  
  def after_commit(message)
    log_prefix = "[Message #{message.id}]"
    
    if message.send(:transaction_include_action?, :create)
      event_name = 'Message Sent'

      # For the orignal message owner (mark as read)
      message.message_proxies.create(:user_id => message.user.id, :unread => false)

      # Message proxies for each other recipient (mark as unread)
      message.engagement.all_participants.reject{ |u| u.id == message.user.id }.each do |recipient|
        message.message_proxies.create(:user_id => recipient.id, :unread => true)
      end
    end

    if message.send(:transaction_include_action?, :destroy)
      event_name = 'Message Deleted'
      # Destroy Committed
    end

    # Track the message event
    Analytics.track(
      user_id: message.user.uuid,
      event: event_name,
      properties: { message_id: message.id }
    )
  end
  
end
