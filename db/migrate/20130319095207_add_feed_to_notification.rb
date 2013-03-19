class AddFeedToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :feed_item, :boolean, :default => true
  end
end
