# == Schema Information
#
# Table name: locations
#
#  id                  :integer         not null, primary key
#  name                :string(255)     not null
#  lat                 :decimal(15, 10)
#  lng                 :decimal(15, 10)
#  facebook_id         :integer(8)
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  locality            :string(255)
#  administrative_area :string(255)
#  country             :string(255)
#

require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
