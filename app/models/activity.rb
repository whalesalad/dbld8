class Activity < ActiveRecord::Base
  attr_accessible :title, :details, :location_id

  validates_presence_of :title, :details

  has_one :user
  has_one :wing

  def to_s
    title
  end
end
