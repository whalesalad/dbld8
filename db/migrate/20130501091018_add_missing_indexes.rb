class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :auth_tokens, :token, :unique => true
    add_index :users, [:id, :type]
    add_index :notifications, :user_id
    add_index :notifications, [:target_id, :target_type]
    add_index :events, [:id, :type]
  end
end
