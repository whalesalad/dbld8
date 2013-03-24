module Concerns
  module RedisConcerns
    extend ActiveSupport::Concern

    def redis_key(str=nil)
      base_key = "#{self.class.model_name.singular}:#{self.id}"
      
      unless str.nil?
        base_key = "#{base_key}:#{str}"
      end

      return base_key
    end

  end
end