class Engagement < ActiveRecord::Base
  before_create :set_default_values

  attr_accessible :activity_id, :message, :status, :user_id, :wing_id

  ENGAGEMENT_STATUS = %w(created viewed accepted ignored)

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

  def participant_names
    participants.map{ |u| u.first_name }.join ' + '
  end

  def as_json(options={})
    exclude = [:updated_at, :wing_id, :user_id]

    result = super({ :except => exclude }.merge(options))

    result[:user] = user.as_json(:mini => true)
    result[:wing] = wing.as_json(:mini => true) if wing.present?
    
    result
  end

end
