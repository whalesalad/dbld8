# == Schema Information
#
# Table name: user_photos
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  image      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'test_helper'

class UserPhotoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
