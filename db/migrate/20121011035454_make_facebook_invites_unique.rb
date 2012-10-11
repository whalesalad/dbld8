class MakeFacebookInvitesUnique < ActiveRecord::Migration
  def change
    add_index :facebook_invites, [:user_id, :facebook_id], :unique => true
    add_index :facebook_invites, [:facebook_id, :user_id], :unique => true
  end
end
