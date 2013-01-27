# == Schema Information
#
# Table name: devices
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  token      :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe Device do
  pending "add some examples to (or delete) #{__FILE__}"
end
