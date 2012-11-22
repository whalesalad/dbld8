# == Schema Information
#
# Table name: user_actions
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  type         :string(255)
#  cost         :integer
#  related_id   :integer
#  related_type :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

require 'test_helper'

class UserActionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
