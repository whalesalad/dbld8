class UserObserver < ActiveRecord::Observer

  def after_commit(user)
    if user.send(:transaction_include_action?, :create)
      Rails.logger.info("[NEW USER] Created user #{user.id}. Welcome to DoubleDate, #{user.full_name}!")
      
      if user.is_a?(FacebookUser)
        FacebookPhotoWorker.perform_async(user.id)
        # FacebookFriendNotifierWorker.perform_async(user.id)
      end

      # Trigger the registration event.
      RegistrationEvent.create(:user => user)
    end
  end
end