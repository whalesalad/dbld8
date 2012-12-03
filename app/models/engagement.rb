# == Schema Information
#
# Table name: engagements
#
#  id          :integer         not null, primary key
#  status      :string(255)
#  user_id     :integer         not null
#  wing_id     :integer         not null
#  activity_id :integer         not null
#  message     :text
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Engagement < ActiveRecord::Base
  before_create :set_default_values

  attr_accessible :activity_id, :message, :status, :user_id, :wing_id

  ENGAGEMENT_STATUS = %w(sent viewed ignored accepted)
  IS_SENT, IS_VIEWED, IS_IGNORED, IS_ACCEPTED = ENGAGEMENT_STATUS

  default_scope order('created_at DESC')

  belongs_to :user
  belongs_to :wing, :class_name => 'User'

  validates_uniqueness_of :activity_id, 
    :scope => [:user_id, :wing_id], 
    :message => "You or your wing have already engaged in this activity."

  # edge case, marcus invites me to go do an activity, but i don't want
  # to do it with him, so i find it myself and want to do it with a
  # different person.

  belongs_to :activity

  def set_default_values
    self.status ||= ENGAGEMENT_STATUS[0]
  end

  def to_s
    "Interest in #{activity}"
  end

  def participants
    [user, wing]
  end

  def all_participants
    (participants | activity.participants)
  end

  def participant_names
    participants.map{ |u| u.first_name }.join ' + '
  end

  def allowed(a_user, permission = :all)
    case permission
    when :owner
      a_user == user
    when :owners
      participants.map(&:id).include? a_user.id
    when :all
      all_participants.map(&:id).include? a_user.id
    end
  end

  def mark_viewed!
    if self.status != IS_VIEWED
      self.status = IS_VIEWED
      self.save!
    end
  end

  def as_json(options={})
    exclude = [:updated_at, :wing_id, :user_id]

    result = super({ :except => exclude }.merge(options))

    result[:user] = user.as_json(:mini => true)
    result[:wing] = wing.as_json(:mini => true) if wing.present?
    
    result
  end

end
