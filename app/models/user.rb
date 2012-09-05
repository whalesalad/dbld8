# == Schema Information
#
# Table name: users
#
#  id            :integer         not null, primary key
#  email         :string(255)
#  password      :string(255)
#  first_name    :string(255)
#  last_name     :string(255)
#  birthday      :date
#  single        :boolean
#  interested_in :string(255)
#  gender        :string(255)
#  bio           :text
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class User < ActiveRecord::Base
  attr_accessible :bio, :birthday, :email, :first_name, :gender, :interested_in, :last_name, :password, :single

  validates_uniqueness_of :email
  
  def as_json(options={})
    exclude = [:created_at, :updated_at, :password]
    result = super({ :except => exclude }.merge(options))
  end
end
