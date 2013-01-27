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
#  unlocked    :boolean         default(FALSE)
#

class Engagement < ActiveRecord::Base
  include Concerns::ParticipantConcerns
  include Concerns::EventConcerns

  attr_accessible :activity_id, :user_id, :wing_id

  scope :ignored, where(:ignored => true)
  scope :not_ignored, where(:ignored => false)

  default_scope order('engagements.updated_at DESC')
  
  validates_uniqueness_of :activity_id, 
    :scope => [:user_id, :wing_id], 
    :message => "You or your wing have already engaged in this activity."

  validates_presence_of :activity_id, :user_id, :wing_id

  belongs_to :activity, :touch => true

  # Messages!
  has_many :messages, :dependent => :destroy
  has_many :message_proxies, :through => :messages

  def send_initial_message(message)
    messages.create(:user => user, :message => message)
  end

  def to_s
    "#{participant_names}: #{activity}"
  end

  def status
    unlocked? ? 'unlocked' : 'locked'
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

  def primary_message
    @message ||= messages.first
  end

  def ignore!
    self.ignored = true
    save!
  end

  def locked?
    !unlocked
  end

  def unlock!
    self.unlocked = true
    save!
  end

  def admin_path
    [:admin, activity, self]
  end

  def as_json(options={})
    "BUILD"
  end

end
