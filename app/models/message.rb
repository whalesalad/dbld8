# == Schema Information
#
# Table name: messages
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  engagement_id :integer
#  body          :text
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class Message < ActiveRecord::Base
  attr_accessible :user, :body

  belongs_to :user
  belongs_to :engagement

  has_one :activity, :through => :engagement
  has_many :message_proxies, :dependent => :destroy

  default_scope order('created_at ASC').includes(:user, :message_proxies)

  def allowed?(a_user, permission = :all)
    a_user.id == user.id
    
    # at the moment this is all that can be done, regardless of permissions
    # case permission
    # when :owner
    #   a_user == user
    # end
  end

  def unread_for(a_user)
    message_proxies.find_by_user_id(a_user.id).unread?
  end

  def as_json(options={})
    'BUILD'
  end

end
