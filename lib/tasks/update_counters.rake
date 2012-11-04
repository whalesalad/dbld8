task :update_counters => :environment do
  # Update the counters for the locations
  Location.pluck(:id).each do |id|
    Location.reset_counters(id, :users, :activities)
  end
end