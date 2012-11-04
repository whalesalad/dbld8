class AddActivitiesCountToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :activities_count, :integer, :default => 0

    say_with_time "Adding activities count to locations..." do
      Location.find_each do |loc|
        Location.reset_counters loc.id, :activities
      end
    end
  end
end
