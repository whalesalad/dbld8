# == Schema Information
#
# Table name: engagements
#
#  id          :integer         not null, primary key
#  status      :string(255)
#  user_id     :integer         not null
#  wing_id     :integer         not null
#  activity_id :integer         not null
#  message     :text
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'test_helper'

class EngagementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
