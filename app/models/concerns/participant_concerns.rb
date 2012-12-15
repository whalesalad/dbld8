module Concerns
  module ParticipantConcerns
    extend ActiveSupport::Concern

    def self.included(base)
      base.class_eval do
        belongs_to :user
        belongs_to :wing, :class_name => 'User'
      end
    end

    def participants
      [user, wing]
    end

    def participant_ids
      [user_id, wing_id]
    end

    def participant_names
      participants.map{ |u| u.first_name }.join ' + '
    end

  end
end
