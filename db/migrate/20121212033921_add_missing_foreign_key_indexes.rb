class AddMissingForeignKeyIndexes < ActiveRecord::Migration
  def change
    add_index :auth_tokens, :user_id
    add_index :user_photos, :user_id
    add_index :users, :location_id

    add_index :user_actions, :user_id
    add_index :user_actions, [:related_id, :related_type]

    add_index :activities, [:location_id]
  end
end


