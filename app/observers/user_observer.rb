class UserObserver < ActiveRecord::Observer
  
  def after_create(user)
    
    Rails.logger.info "NEW USER! #{user.id} - #{user.first_name}"

    NewUserWorker.perform_async(user.id)

    # Reward the user who sent an invite to this new user
    if user.is_a?(FacebookUser)
      RewardFacebookInviteWorker.perform_async(user.id)
    end
  end

end