module Concerns
  module EventConcerns
    extend ActiveSupport::Concern

    included do
      has_many :events,
        :as => :related

      # we'd like to destroy all notifications if this gets destroyed
      has_many :notifications,
        :through => :events

      after_destroy :clean_orphaned_events_and_notifications
    end

    def destroy_all_notifications!
      events.each do |e|
        e.notifications.delete_all
      end
    end

    private

    def clean_orphaned_events_and_notifications      
      events.each do |e|
        e.notifications.delete_all
        e.related = nil
        e.save!
      end
    end

  end
end