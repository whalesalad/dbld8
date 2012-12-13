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
  include Mixins::Participants

  before_create :set_default_values
  after_commit :send_initial_message, :on => :create

  attr_accessor :message
  attr_accessible :activity_id, :message, :status, :user_id, :wing_id

  ENGAGEMENT_STATUS = %w(sent viewed ignored accepted)
  IS_SENT, IS_VIEWED, IS_IGNORED, IS_ACCEPTED = ENGAGEMENT_STATUS

  default_scope order('created_at DESC')
  
  scope :not_ignored, where('status != ?', IS_IGNORED)
  
  scope :sent, where(:status => IS_SENT)
  scope :viewed, where(:status => IS_VIEWED)
  scope :ignored, where(:status => IS_IGNORED)
  scope :accepted, where(:status => IS_ACCEPTED)

  validates_uniqueness_of :activity_id, 
    :scope => [:user_id, :wing_id], 
    :message => "You or your wing have already engaged in this activity."

  # edge case, marcus invites me to go do an activity, but i don't want
  # to do it with him, so i find it myself and want to do it with a
  # different person.

  belongs_to :activity

  # Messages!
  has_many :messages, :dependent => :destroy

  def self.find_for_user_or_wing(user_id)
    where('user_id = ? OR wing_id = ?', user_id, user_id).first
  end

  def set_default_values
    self.status ||= IS_SENT
  end

  def send_initial_message
    messages.create :user_id => user.id, :message => message
  end

  def to_s
    "Interest in #{activity}"
  end

  def all_participants
    (participants | activity.participants)
  end

  def all_participant_ids
    (participant_ids | activity.participant_ids)
  end

  def allowed?(a_user, permission = :all)
    case permission
    when :owner
      a_user == user
    when :owners
      participant_ids.include? a_user.id
    when :all
      all_participant_ids.include? a_user.id
    end
  end

  def message
    @message ||= messages.first
  end

  def viewed!
    self.status = IS_VIEWED
    self.save!
  end

  def ignore!
    self.status = IS_IGNORED
    self.save!
  end

  def accept!
    self.status = IS_ACCEPTED
    self.save!
  end

  def as_json(options={})
    exclude = [:updated_at, :wing_id, :user_id]

    result = super({ :except => exclude }.merge(options))

    result[:messages_count] = messages.count

    result[:user] = user.as_json(:mini => true)
    result[:wing] = wing.as_json(:mini => true) if wing.present?
    
    result
  end

end
