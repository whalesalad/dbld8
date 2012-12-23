# == Schema Information
#
# Table name: messages
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  engagement_id :integer
#  message       :text
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

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

  def as_json(options={})
    exclude = [:updated_at, :engagement_id]

    result = super({ :except => exclude }.merge(options))

    result[:first_name] = user.first_name
    
    result
  end

end
