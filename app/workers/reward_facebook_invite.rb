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

class RewardFacebookInvite
  @queue = :user_actions

  def self.perform(invite_id)
    invite = FacebookInvite.find invite_id

    begin
      invite.user.trigger('recruit', invite) if invite
    rescue ActiveRecord::RecordInvalid => invalid
      puts "Recruit credits have already been awarded."
    end
  end
end