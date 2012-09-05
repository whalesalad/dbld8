# == Schema Information
#
# Table name: users
#
#  id            :integer         not null, primary key
#  email         :string(255)
#  password      :string(255)
#  first_name    :string(255)
#  last_name     :string(255)
#  birthday      :date
#  single        :boolean
#  interested_in :string(255)
#  gender        :string(255)
#  bio           :text
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
