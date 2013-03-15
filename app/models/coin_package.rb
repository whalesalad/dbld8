# == Schema Information
#
# Table name: coin_packages
#
#  id              :integer         not null, primary key
#  identifier      :string(255)
#  coins           :integer
#  popular         :boolean         default(FALSE)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  purchases_count :integer         default(0)
#

class CoinPackage < ActiveRecord::Base
  attr_accessible :coins, :identifier, :popular

  validates_uniqueness_of :identifier

  has_many :purchases,
    foreign_key: 'identifier',
    primary_key: 'identifier',
    inverse_of: :coin_package

  default_scope order('coins')

  def to_s
    name
  end

  def name
    "#{coins} Coins"
  end

end
