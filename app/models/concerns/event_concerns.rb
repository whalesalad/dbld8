module Concerns
  module EventConcerns
    extend ActiveSupport::Concern

    included do
      has_many :events, 
        :as => :related,
        :dependent => :nullify
    end
  end
end