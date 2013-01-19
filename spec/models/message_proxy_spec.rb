# == Schema Information
#
# Table name: message_proxies
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  message_id :integer
#  unread     :boolean         default(TRUE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe MessageProxy do
  pending "add some examples to (or delete) #{__FILE__}"
end
