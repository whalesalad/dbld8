class AddUnlockableToEngagement < ActiveRecord::Migration
  def up
    add_column :engagements, :unlocked, :boolean, :default => false
  end

  def down
    remove_column :engagements, :unlocked
  end
end
