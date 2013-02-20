class MaxActivityUnlockerService
  attr_accessor :user, :errors

  def initialize(user)
    @user = user
    @errors = []
  end

  def unlock_intervals
    [5, 10]
  end

  def unlock_events
    [UnlockedFiveActivitiesEvent, UnlockedTenActivitiesEvent]
  end

  def activities_allowed
    user.features['max_activities'].to_i
  end

  def activities_count
    user.activities.count
  end

  def can_post_activity?
    activities_count < activities_allowed
  end
  
  def needs_unlock?
    !can_post_activity?
  end

  def can_unlock?(to_unlock)
    @errors.clear

    if next_unlock_event != to_unlock
      @errors << "The user is not allowed to unlock the requested level."
    end

    unless user.can_spend?(to_unlock.coin_value)
      @errors << "The user cannot afford the requested level."
    end

    return @errors.empty?
  end

  def unlock!(slug)
    to_unlock = Event.from_slug(slug)

    return false unless can_unlock?(to_unlock)

    unlock_event = to_unlock.new
    unlock_event.user = user

    if unlock_event.save!
      user.features['max_activities'] = next_unlock_interval
      user.save!

      return unlock_event
    end
    
    return false
  end

  def lowest_level?
    unlock_intervals.index(activities_allowed).nil?
  end

  def highest_level?
    activities_allowed == unlock_intervals.last
  end

  def next_unlock_index
    return false if highest_level?

    # First unlock if we're at the lowest level
    return 0 if lowest_level?
    
    # Next best thing at this point
    return unlock_intervals.index(activities_allowed) + 1
  end

  def next_unlock_interval
    false unless next_unlock_index
    unlock_intervals[next_unlock_index]
  end

  def next_unlock_event
    false unless next_unlock_index
    unlock_events[next_unlock_index]
  end

end