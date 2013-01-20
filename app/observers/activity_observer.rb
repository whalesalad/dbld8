class ActivityObserver < ActiveRecord::Observer

  def after_commit(activity)
    if activity.send(:transaction_include_action?, :create)
      # Create NewActivityAction
      NewActivityEvent.create(:user => activity.user, :related => activity)
    end

    # Send notification to wing
    #  - You're Ivan's wing on his new DoubleDate "Venice Beach Barhopping"
    #  - You're Vanessa's wing on her new DoubleDate "Hiking in Manoa Valley"
  end

  def after_destroy(activity)
    # User leaves a date
    
    # this code belongs in one location and should notify all four users at once.

    # Send notification to opposite couple
    # Jenny + Vanessa bailed out on "DoubleDateName"
    # engaged_users.each_couple.notify('#{activiy.user.first_name} + #{activiy.wing.first_name} bailed out on #{activity.name}.')
    
    # send notification to other user in leaving person's couple
    # Jenny bailed out on "DoubleDateName"
    # 
  end

end