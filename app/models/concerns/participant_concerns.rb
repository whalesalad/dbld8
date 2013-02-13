module Concerns
  module ParticipantConcerns
    extend ActiveSupport::Concern

    included do
      belongs_to :user
      belongs_to :wing, :class_name => 'User'
    end

    module ClassMethods
      def find_for_user_or_wing(user_id)
        user_id = user_id.id if user_id.is_a?(User) 
        where('user_id = ? OR wing_id = ?', user_id, user_id)
      end
    end

    def participants
      [user, wing]
    end

    def participant_ids
      [user_id, wing_id]
    end

    def participant_names
      participants.map{ |u| u.first_name }.join ' and '
    end

    def photos
      participants.map {|u| u.photo }
    end

  end
end
