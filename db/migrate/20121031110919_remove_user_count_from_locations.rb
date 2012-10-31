class RemoveUserCountFromLocations < ActiveRecord::Migration
  def change
    remove_column :locations, :users_count
  end
end
