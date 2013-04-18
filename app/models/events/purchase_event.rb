# == Schema Information
#
# Table name: events
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  type         :string(255)
#  coins        :integer
#  related_id   :integer
#  related_type :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  karma        :integer         default(0)
#

class PurchaseEvent < Event
  alias purchase related

  def detail_string_params
    { user_name: user.to_s, identifier: purchase.identifier }
  end

  def human_name
    "#{super}: #{purchase.coins} Coins"
  end
end
