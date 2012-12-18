# == Schema Information
#
# Table name: activities
#
#  id                   :integer         not null, primary key
#  title                :string(255)     not null
#  details              :string(255)
#  day_pref             :string(255)
#  time_pref            :string(255)
#  location_id          :integer
#  user_id              :integer         not null
#  wing_id              :integer         not null
#  status               :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  active_engagement_id :integer
#

require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
