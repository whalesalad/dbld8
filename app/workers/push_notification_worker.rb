class PushNotificationWorker
  include Sidekiq::Worker

  # Set a global connection to APN one single time
  APN_CONNECTION = Grocer.pusher(
    certificate: Rails.root.join("cert/apn_#{Rails.configuration.apn_mode}.pem"),
    gateway: Rails.configuration.apn_gateway
  )

  def perform(n_id)
    notification = Notification.find_by_id(n_id)

    if notification && notification.pushable?
      # return unless notification.user.primary_device_token.present?

      # Need to loop the user's devices and make notifications for each device
      notification.user.devices.each do |device|
        push_notification = Grocer::Notification.new({
          device_token: device, 
          alert: notification.to_s
        })
        APN_CONNECTION.push(push_notification)
      end

      notification.pushed!
    end
  end
end