class AdjustmentsToEngagement < ActiveRecord::Migration
  def change
    remove_column :engagements, :message
  end
end
