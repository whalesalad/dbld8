class RemoveUuidFromFriendships < ActiveRecord::Migration
  def change
    remove_column :friendships, :uuid
  end
end
