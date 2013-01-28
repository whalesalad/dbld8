class PushFeedbackWorker
  include Sidekiq::Worker

  # Set a global connection to APN one single time
  APN_FEEDBACK = Grocer.feedback(
    certificate: Rails.root.join("cert/apn_#{Rails.configuration.apn_mode}.pem"),
    gateway: Rails.configuration.apn_feedback
  )

  def perform
    puts "[APN Feedback] Beginning routine check for dead devices."

    to_destroy = []

    # Find the devices to destroy.
    APN_FEEDBACK.each do |attempt|
      puts "[APN Feedback] Device #{attempt.device_token} failed at #{attempt.timestamp}."
      to_destroy << attempt.device_token
    end

    # Destroy the devices.
    Device.destroy_all(:token => to_destroy)
    puts "[APN Feedback] Finished. #{to_destroy.size} device(s) were removed."
  end
end