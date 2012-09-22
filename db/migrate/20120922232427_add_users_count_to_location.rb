class AddUsersCountToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :users_count, :integer, :default => 0

    say_with_time "Adding user count to locations..." do
      Location.find_each do |loc|
        Location.reset_counters loc.id, :users
      end
    end
    
  end
end
