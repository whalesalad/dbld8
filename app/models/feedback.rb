class Feedback < ActiveRecord::Base
  attr_accessible :user_id, :message

  belongs_to :user

  validates_presence_of :user, :message

  def to_s
    "Feedback from #{user}"
  end
end
