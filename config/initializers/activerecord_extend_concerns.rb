# Extend AR with some of our own concerns
ActiveRecord::Base.send(:include, Concerns::NotificationConcerns)
ActiveRecord::Base.send(:include, Concerns::RedisConcerns)