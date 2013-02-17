class PushNotificationWorker
  include Sidekiq::Worker

  # Set a global connection to APN one single time
  APN_CONNECTION = Grocer.pusher(
    certificate: Rails.root.join("cert/apn_#{Rails.configuration.apn_mode}.pem"),
    gateway: Rails.configuration.apn_gateway
  )

  def perform(n_id, force=nil)
    notification = Notification.find_by_id(n_id)

    do_send = (force.present?) ? true : notification.pushable?

    if notification && do_send
      # Need to loop the user's devices and make notifications for each device
      notification.user.devices.each do |device|
        push_notification = Grocer::Notification.new(
          device_token: device.token, 
          alert: notification.to_s,
          badge: notification.user.notifications.unread.count,
          identifier: notification.id,
          custom: { callback_url: notification.callback_url }
        )

        APN_CONNECTION.push(push_notification)
      end

      notification.pushed! unless force.present?
    end
  end
end