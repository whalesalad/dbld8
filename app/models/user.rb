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
  has_secure_password

  attr_accessible :bio, :birthday, :email, :first_name, :gender, :interested_in, :last_name, :password, :single

  GENDER_CHOICES = %w(male female)
  INTEREST_CHOICES = %w(guys girls both)

  validates_uniqueness_of :email
  validates_presence_of :first_name, :last_name, :birthday, :gender

  validates_inclusion_of :gender, :in => GENDER_CHOICES
  validates_inclusion_of :interested_in, :in => INTEREST_CHOICES

  # Handles calculating the users' age (even with leap year!)
  def age
    now = Time.now.utc.to_date
    now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
  end

  def as_json(options={})
    exclude = [:created_at, :updated_at, :password_digest]
    result = super({ :except => exclude }.merge(options))
    
    # Add some goodies
    result[:age] = age
    result[:photo] = nil

    result
  end
end
