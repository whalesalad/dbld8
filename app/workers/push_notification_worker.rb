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
      return unless notification.user.primary_device_token.present?

      push_notification = Grocer::Notification.new(
        device_token: notification.user.primary_device_token,
        alert:        notification.to_s,
        # badge:        42,
        # sound:        "siren.aiff",         # optional
        # expiry:       Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
        # identifier:   1234                  # optional
      )

      APN_CONNECTION.push(push_notification)

      # notification.pushed!
    end
  end



end