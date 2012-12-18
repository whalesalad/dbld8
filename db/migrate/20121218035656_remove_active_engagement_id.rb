class RemoveActiveEngagementId < ActiveRecord::Migration
  def change
    remove_column :activities, :active_engagement_id
  end
end
