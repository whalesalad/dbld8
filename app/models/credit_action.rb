class CreditAction < ActiveRecord::Base
  attr_accessible :slug, :cost

  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /\A[[a-z\_]+[\/?]*]+\Z/

  validates_presence_of :slug, :cost

  def to_s
    "#{slug} (#{cost})"
  end

end
