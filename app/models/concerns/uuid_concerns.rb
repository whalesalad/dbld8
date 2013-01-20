module Concerns
  module UUIDConcerns
    extend ActiveSupport::Concern

    included do
      before_create :set_uuid
    end

    def set_uuid
      require 'securerandom'
      self.uuid = SecureRandom.uuid
    end
    
  end
end