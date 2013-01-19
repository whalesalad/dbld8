class RemoveStatusFromEngagement < ActiveRecord::Migration
  def up
    remove_column :engagements, :status
  end

  def down
    add_column :engagements, :status, :string
  end
end
