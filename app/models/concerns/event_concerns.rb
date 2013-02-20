module Concerns
  module EventConcerns
    extend ActiveSupport::Concern

    included do
      has_many :events, 
        :as => :related,
        :dependent => :nullify

      # we'd like to destroy all notifications if this gets destroyed
      has_many :notifications,
        :through => :events,
        :dependent => :destroy

    end
    
  end
end