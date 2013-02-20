class UnlockEngagementService
  attr_accessor :engagement, :user, :unlock_cost, :unlockable

  def initialize(engagement, user)
    @engagement = engagement
    @user = user
  end

  def unlock_cost
    @unlock_cost ||= UnlockedEngagementEvent.coin_value
  end

  def activity
    engagement.activity
  end

  def unlockable?
    self.unlockable ||= can_unlock?
  end

  def can_unlock?
    # ensure the user is the owner or wing on the activity
    return false unless activity.allowed?(user, :owners)

    # ensure that the user has at least X cost of whatever this event costs
    return false unless user.can_spend?(unlock_cost)

    # If both conditions pass, we can unlock
    true
  end

  def unlock!
    # performs the unlock, if allowed
    return false unless (unlockable? && engagement.locked?)

    # Do all of this in a transaction
    ActiveRecord::Base.transaction do
      # Create the event for the user
      event = UnlockedEngagementEvent.create(:user => user, :related => engagement)
    
      # set the unlocked flag to true on the engagement
      engagement.unlock!

      return true
    end

    false
  end
end