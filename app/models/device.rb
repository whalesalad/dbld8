class Device < ActiveRecord::Base
  attr_accessible :token
  
  validates_uniqueness_of :token
  validates_presence_of :token

  belongs_to :user
end
