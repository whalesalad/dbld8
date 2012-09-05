# == Schema Information
#
# Table name: interests
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  facebook_id :integer(8)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Interest < ActiveRecord::Base
  attr_accessible :facebook_id, :name

  validates_uniqueness_of :name
  validates_uniqueness_of :facebook_id, :allow_nil => true

  def as_json(options={})
    result = super({ :except => [:created_at, :updated_at] }.merge(options))
  end
end
