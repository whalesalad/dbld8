class Notification < ActiveRecord::Base
  include Concerns::UUIDConcerns

  attr_accessible :user, :event, :push, :callback

  # before_create :set_callback

  belongs_to :user
  belongs_to :event

  def read?
    !unread?
  end

  def set_callback
    # self.callback ||= 
    # if event.related.is_a?(Activity), open the activity

    # if event.is_a?(NewActivityEvent)

    # end
  end

end


# Wing gets notified they are part of a date
# event is_a NewActivityEvent
# user == event.activity.wing
#  - You're Ivan's wing on his new DoubleDate "Venice Beach Barhopping"
#  - You're Vanessa's wing on her new DoubleDate "Hiking in Manoa Valley"