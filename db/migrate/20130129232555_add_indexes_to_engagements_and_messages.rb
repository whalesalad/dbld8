class AddIndexesToEngagementsAndMessages < ActiveRecord::Migration
  def change
    add_index :engagements, :activity_id
    add_index :engagements, :ignored 
    add_index :message_proxies, :user_id
    add_index :message_proxies, :message_id
    add_index :message_proxies, :unread
  end
end
