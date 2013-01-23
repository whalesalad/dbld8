class UserObserver < ActiveRecord::Observer
  
  def after_create(user)
    # Trigger the registration event.
    RegistrationEvent.create(:user => user)

    # Reward the user who sent an invite to this new user
    # XXXX TODO FIXME
    # if user.is_a?(FacebookUser)
    #   RewardFacebookInviteWorker.perform_async(user.id)
    # end
  end

end