module Concerns
  module NotificationConcerns
    extend ActiveSupport::Concern

    def notification_url
      "#{self.class.model_name.plural}/#{self.id}"
    end

    def app_identifier
      "#{self.class.model_name}/#{self.id}"
    end

  end
end