class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.uuid :uuid, :null => false
      t.integer :user_id, :null => false
      t.integer :event_id, :null => false
      
      t.boolean :unread, :default => true
      t.boolean :push, :default => false
      t.boolean :pushed, :default => false

      t.string :callback

      t.timestamps
    end

    # There should never be more than one notification per user, per event.
    # I should not be told twice that X happened.
    add_index :notifications, [:user_id, :event_id], :unique => true
  end
end
