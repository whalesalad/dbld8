# == Schema Information
#
# Table name: locations
#
#  id               :integer         not null, primary key
#  locality         :string(255)
#  state            :string(255)
#  country          :string(255)
#  latitude         :float
#  longitude        :float
#  facebook_id      :integer(8)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  foursquare_id    :string(255)
#  venue            :string(255)
#  users_count      :integer         default(0)
#  address          :string(255)
#  geoname_id       :integer
#  activities_count :integer         default(0)
#  foursquare_icon  :string(255)
#  population       :integer(8)
#

require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
