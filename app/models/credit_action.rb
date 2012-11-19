# == Schema Information
#
# Table name: credit_actions
#
#  id         :integer         not null, primary key
#  slug       :string(255)
#  cost       :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class CreditAction < ActiveRecord::Base
  include Concerns::CostConcerns

  attr_accessible :slug, :cost

  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /\A[[a-z\_]+[\/?]*]+\Z/

  validates_presence_of :slug, :cost

  def to_s
    "#{slug} (#{cost_to_s})"
  end

  def to_param
    slug
  end

  def mapped
    "#{slug}_action".classify
  end

end
