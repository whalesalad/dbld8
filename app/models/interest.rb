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

  attr_accessor :matched

  default_scope order('name')

  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :facebook_id, :allow_nil => true

  has_and_belongs_to_many :users

  def to_s
    name
  end

  def as_json(options={})
    result = super({ :only => [:id, :name] })
  end
end
