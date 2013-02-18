class UserObserver < ActiveRecord::Observer

  def after_commit(user)
    if user.send(:transaction_include_action?, :create)
      Rails.logger.info("[NEW USER] Created user #{user.id}. Welcome to DoubleDate, #{user.full_name}!")
      
      if user.is_a?(FacebookUser)
        FacebookPhotoWorker.perform_async(user.id)
        FacebookInterestsWorker.perform_async(user.id)
      end

      # Trigger the registration event.
      RegistrationEvent.create(:user => user)
    end
  end
  
  # Reward the user who sent an invite to this new user
  # XXXX TODO FIXME
  # if user.is_a?(FacebookUser)
  #   RewardFacebookInviteWorker.perform_async(user.id)
  # end

end