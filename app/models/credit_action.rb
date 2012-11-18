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
  attr_accessible :slug, :cost

  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /\A[[a-z\_]+[\/?]*]+\Z/

  validates_presence_of :slug, :cost

  def earns?
    cost > 0
  end

  def spends?
    cost < 0
  end

  def to_s
    "#{slug} (#{cost_to_s})"
  end

  def to_param
    slug
  end

  def prefix
    earns? ? '+' : '-'
  end

  def cost_to_s
    "#{prefix}#{cost.abs}"
  end

end
