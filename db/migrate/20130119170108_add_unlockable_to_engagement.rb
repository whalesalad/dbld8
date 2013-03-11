class AddUnlockableToEngagement < ActiveRecord::Migration
  def change
    add_column :engagements, :unlocked, :boolean, :default => false
  end
end
