# == Schema Information
#
# Table name: friendships
#
#  id         :integer         not null, primary key
#  uuid       :uuid            not null
#  user_id    :integer         not null
#  friend_id  :integer         not null
#  approved   :boolean         default(FALSE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
