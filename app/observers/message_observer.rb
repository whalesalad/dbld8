class MessageObserver < ActiveRecord::Observer
  
  def after_commit(message)
    log_prefix = "[Message #{message.id}]"
    
    if message.send(:transaction_include_action?, :create)
      Rails.logger.info "#{log_prefix} NEW MESSAGE #{message.id} from #{message.user.first_name}"

      # For the orignal message owner (mark as read)
      message.message_proxies.create(:user_id => message.user.id, :unread => false)

      # Message proxies for each other recipient (mark as unread)
      message.engagement.all_participants.reject{ |u| u.id == message.user.id }.each do |recipient|
        message.message_proxies.create(:user_id => recipient.id, :unread => true)
      end

    end

    if message.send(:transaction_include_action?, :destroy)
      Rails.logger.info "#{log_prefix} MESSAGE DESTROYED: #{message.id} from #{message.user.first_name}"
    end
    
    # Send notification to other users:
    # engagement.participants.exclude(message.user).notify...
    
    # pseudocode???
    # message.engagement.notify_participants_of_new_message

    # "You have a new message from Jenny on "#{message.activity.title}"
  end

end