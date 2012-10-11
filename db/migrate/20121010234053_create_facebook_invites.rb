class CreateFacebookInvites < ActiveRecord::Migration
  def change
    create_table :facebook_invites do |t|
      t.integer :user_id
      t.integer :facebook_id, :limit => 8

      t.timestamps
    end

    add_index :facebook_invites, [:user_id, :facebook_id], :unique => true
    add_index :facebook_invites, [:facebook_id, :user_id], :unique => true

  end
end
