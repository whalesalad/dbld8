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

require 'test_helper'

class InterestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
