# == Schema Information
#
# Table name: feedback
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  message    :text
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Feedback < ActiveRecord::Base
  attr_accessible :user_id, :message

  belongs_to :user

  validates_presence_of :user, :message

  def to_s
    "Feedback from #{user}"
  end
end
