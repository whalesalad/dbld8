class Device < ActiveRecord::Base
  attr_accessible :token
  
  validates_uniqueness_of :token
  validates_presence_of :token

  belongs_to :user

  def as_json(options)
    super(:only => [:token, :updated_at])
  end
end
