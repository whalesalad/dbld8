class RemoveUnlockedBoolFromEngagements < ActiveRecord::Migration
  def up
    remove_column :engagements, :unlocked
  end

  def down
    add_column :engagements, :unlocked, :boolean, :default => false
  end
end
