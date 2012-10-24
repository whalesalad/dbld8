# == Schema Information
#
# Table name: facebook_invites
#
#  id          :integer         not null, primary key
#  user_id     :integer
#  facebook_id :integer(8)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'test_helper'

class FacebookInviteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
