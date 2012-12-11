class Message < ActiveRecord::Base
  attr_accessible :user_id, :message

  belongs_to :user
  belongs_to :engagement
end
