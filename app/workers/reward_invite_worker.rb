# marcus invites me.
# i accept, and join the app.
# in doing this, i suddenly have an "inverse_facebook_invite"
# this means that marcus and myself deserve credits.
# >>> RecruitedFacebookUser

# pseudocode

# 1) Give the user who created this invite some credits
# >>> invite_user.credits += 10

# 2) Create a friendship request between the creator <=> this new user.
# >>> invite_user.invite(self)

class RewardFacebookInviteWorker
  include Sidekiq::Worker

  def perform(new_user_id)
    new_user = User.find(new_user_id)
    facebook_invitation = new_user.target_facebook_invite

    return if facebook_invitation.blank?

    begin
      # Trigger the recruit action
      # Ultimately this should send a notification to the user
      facebook_invitation.user.trigger('recruit', facebook_invitation)
    rescue ActiveRecord::RecordInvalid => invalid
      puts "Recruit credits have already been awarded."
    end

    # Connect the two users, and approve the friendship
    # The user who sent the invite is inviting the new user
    facebook_invitation.user.invite(new_user, true)
  end

end