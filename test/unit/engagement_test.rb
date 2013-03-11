# == Schema Information
#
# Table name: engagements
#
#  id          :integer         not null, primary key
#  user_id     :integer         not null
#  wing_id     :integer         not null
#  activity_id :integer         not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  ignored     :boolean         default(FALSE)
#  unlocked    :boolean         default(FALSE)
#  unlocked_at :datetime
#

require 'test_helper'

class EngagementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
