class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.uuid      :friendship_uuid, :null => false
      t.integer   :user_id, :null => false
      t.integer   :friend_id, :null => false

      t.boolean   :approved, :default => false

      t.timestamps
    end
    
    add_index :friendships, [:user_id, :friend_id], :unique => true
    add_index :friendships, [:friend_id, :user_id], :unique => true
    
    # Handle the UUID noise, which actually is no longer necessary we do this in the code.
    execute 'ALTER TABLE friendships ALTER COLUMN friendship_uuid SET DEFAULT uuid_generate_v4();';
  end
end
