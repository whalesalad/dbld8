class CreateMessageProxies < ActiveRecord::Migration
  def change
    create_table :message_proxies do |t|
      t.integer :user_id
      t.integer :message_id
      t.boolean :unread, :default => true

      t.timestamps
    end

    # add_index :credit_actions, :slug, :unique => true
    add_index :message_proxies, [:user_id, :message_id], :unique => true
  end
end
