class AddIgnoredToEngagement < ActiveRecord::Migration
  def change
    add_column :engagements, :ignored, :boolean, :default => false
  end
end
