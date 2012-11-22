class Engagement < ActiveRecord::Base
  before_create :set_default_values

  attr_accessible :activity_id, :message, :status, :user_id, :wing_id

  ENGAGEMENT_STATUS = %w(created viewed engaged ignored)

  default_scope order('created_at DESC')

  belongs_to :user
  belongs_to :wing, :class_name => 'User'

  belongs_to :activity

  def set_default_values
    self.status ||= 'created'
  end

  def to_s
    "Interest in #{activity}"
  end

  def participants
    [wing, user]
  end

  def participant_names
    participants.map{ |u| u.first_name }.join ' + '
  end
end
