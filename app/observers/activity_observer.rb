class ActivityObserver < ActiveRecord::Observer

  def after_create(activity)
    log_prefix = "[Activity #{activity.id}]"

    Rails.logger.info "#{log_prefix} NEW ACTIVITY: #{activity.id} '#{activity.title}' from #{activity.user.first_name}."

    Rails.logger.info "#{log_prefix} NEW NOTIFICATION: You're #{activity.user.first_name}'s wing on #{activity.user.gender_posessive} new DoubleDate '#{activity.title}'."
    
    # Create NewActivityAction
    activity.user.trigger 'activity_create', activity

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