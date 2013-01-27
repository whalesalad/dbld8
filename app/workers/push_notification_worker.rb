class PushNotificationWorker
  include Sidekiq::Worker

  attr_accessor :pusher

  def pusher
    @pusher ||= Grocer.pusher(certificate: Rails.root.join("cert/apn_dev.pem"))
  end

  def perform(n_id)
    notification = Notification.find_by_id(n_id)

    if notification && notification.pushable?
      push_notification = Grocer::Notification.new(
        device_token: notification.user.primary_device_token,
        alert:        notification.to_s,
        badge:        42,
        # sound:        "siren.aiff",         # optional
        # expiry:       Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
        # identifier:   1234                  # optional
      )

      pusher.push(push_notification)

      # notification.pushed!
    end
  end



end