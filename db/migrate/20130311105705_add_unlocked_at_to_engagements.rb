class AddUnlockedAtToEngagements < ActiveRecord::Migration
  def change
    add_column :engagements, :unlocked_at, :datetime
  end
end
