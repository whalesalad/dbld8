# Sidekiq.configure_server do |config|
#   config.
# end

module Sidekiq
  def self.pusher
    @pusher ||= self.establish_pusher
  end

  def self.establish_pusher
    puts "Creating new Grocer APN connection..."
    
    Grocer.pusher(
      certificate: Rails.root.join("cert/apn_#{Rails.env}.pem"),
      gateway: "gateway.sandbox.push.apple.com"
    )
  end
end