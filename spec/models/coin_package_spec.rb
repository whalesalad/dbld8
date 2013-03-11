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

require 'spec_helper'

describe CoinPackage do
  pending "add some examples to (or delete) #{__FILE__}"
end
