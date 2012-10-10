class CreateFacebookInvites < ActiveRecord::Migration
  def change
    create_table :facebook_invites do |t|
      t.integer :user_id
      t.integer :facebook_id, :limit => 8

      t.timestamps
    end
  end
end
