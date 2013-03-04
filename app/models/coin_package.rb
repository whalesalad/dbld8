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
