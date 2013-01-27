# == Schema Information
#
# Table name: devices
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  token      :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Device < ActiveRecord::Base
  attr_accessible :token
  
  validates_uniqueness_of :token
  validates_presence_of :token

  belongs_to :user

  def as_json(options)
    super(:only => [:token, :updated_at])
  end
end
