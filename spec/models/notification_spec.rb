# == Schema Information
#
# Table name: notifications
#
#  id         :integer         not null, primary key
#  uuid       :uuid            not null
#  user_id    :integer         not null
#  event_id   :integer         not null
#  unread     :boolean         default(TRUE)
#  push       :boolean         default(FALSE)
#  pushed     :boolean         default(FALSE)
#  callback   :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe Notification do
  pending "add some examples to (or delete) #{__FILE__}"
end
