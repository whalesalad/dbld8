# == Schema Information
#
# Table name: purchases
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  identifier :string(255)     not null
#  receipt    :text            not null
#  verified   :boolean
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe Purchase do
  pending "add some examples to (or delete) #{__FILE__}"
end
