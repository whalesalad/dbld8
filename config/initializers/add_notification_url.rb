# include the extension 
ActiveRecord::Base.send(:include, Concerns::NotificationConcerns)