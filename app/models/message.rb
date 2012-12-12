class Message < ActiveRecord::Base
  attr_accessible :user_id, :message

  belongs_to :user
  belongs_to :engagement

  def allowed?(a_user, permission = :all)
    case permission
    when :owner, :modify
      a_user == user
    when :all
      engagement.participant_ids.include?(a_user.id)
    end
  end

  

end
