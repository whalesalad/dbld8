# == Schema Information
#
# Table name: coin_packages
#
#  id         :integer         not null, primary key
#  identifier :string(255)
#  coins      :integer
#  popular    :boolean         default(FALSE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class CoinPackage < ActiveRecord::Base
  attr_accessible :coins, :identifier, :popular

  validates_uniqueness_of :identifier

  default_scope order('coins')

  def to_s
    name
  end

  def name
    "#{coins} Coins"
  end

end
