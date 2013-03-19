# == Schema Information
#
# Table name: engagements
#
#  id          :integer         not null, primary key
#  user_id     :integer         not null
#  wing_id     :integer         not null
#  activity_id :integer         not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  ignored     :boolean         default(FALSE)
#  unlocked_at :datetime
#

class Engagement < ActiveRecord::Base
  include Concerns::ParticipantConcerns
  include Concerns::EventConcerns

  EXPIRATION_DAYS = 5.days

  attr_accessible :activity_id, :user_id, :wing_id

  validates_presence_of :activity_id, :user_id, :wing_id

  belongs_to :activity, :touch => true

  validates_uniqueness_of :activity_id, 
    :scope => [:user_id, :wing_id], 
    :message => "You or your wing have already engaged in this activity."

  validate :validate_unique_participants, :on => :create

  # Messages!
  has_many :messages, :dependent => :destroy
  has_many :message_proxies, :through => :messages

  default_scope order('engagements.updated_at DESC')

  scope :ignored, where(:ignored => true)
  scope :not_ignored, where(:ignored => false)

  # Status, days remaining etc...
  scope :unlocked, where("unlocked_at > ?", EXPIRATION_DAYS.ago)
  scope :expired, where("unlocked_at < ?", EXPIRATION_DAYS.ago)
  
  scope :three_days_left, where(unlocked_at: 2.days.ago..(2.days.ago+1.hour))
  scope :one_day_left, where(unlocked_at: 4.days.ago..(4.days.ago+1.hour))
  scope :to_be_expired, where(unlocked_at: EXPIRATION_DAYS.ago..(EXPIRATION_DAYS.ago+1.hour))

  scope :for_user, lambda {|user|
    select('distinct(engagements.id)')
      .includes(:activity, :user => [:profile_photo, :location], :wing => [:profile_photo, :location])
      .where('activities.user_id = ? OR activities.wing_id = ? OR engagements.user_id = ? OR engagements.wing_id = ?', user.id, user.id, user.id, user.id)
  }

  # I want all engagements that have message proxies with unread = true
  scope :unread_for, lambda {|user|
    joins(:message_proxies).where('message_proxies.user_id' => user.id).where('message_proxies.unread' => true)
  }

  def self.expires_in(num_days)
    # Find the dates that expire in the next 3 days, within current hour.
    self.where("unlocked_at > ?", num_days.days.ago)
  end
  
  def send_initial_message(message)
    messages.create(:user => user, :message => message)
  end

  def to_s
    "#{participant_names}: #{activity}"
  end

  def status
    if was_unlocked?
      unlocked? ? 'unlocked' : 'expired'
    else
      'locked'
    end
  end

  def all_participants
    (participants | activity.participants)
  end

  def all_participant_ids
    (participant_ids | activity.participant_ids)
  end

  def unique_participants?
    all_participant_ids.uniq.size == 4
  end

  def validate_unique_participants
    errors.add(:users, "An Engagement cannot contain users that belong to the Activity. All four users must be unique.") unless unique_participants?
  end

  def engagement_messages
    messages.where(:user_id => participant_ids)
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

  def primary_message
    @message ||= messages.first
  end

  def ignore!
    self.ignored = true
    save!
  end

  def expired?
    unlocked_at.present? && unlocked_at < EXPIRATION_DAYS.ago
  end

  def locked?
    unlocked_at.blank? || expired?
  end

  def unlocked?
    !locked?
  end

  def unlock!
    self.unlocked_at = Time.now
    save!
  end

  def was_unlocked?
    self.unlocked_at.present?
  end

  def expires_at
    unlocked_at + EXPIRATION_DAYS
  end

  def as_json(options={})
    "BUILD"
  end

end
