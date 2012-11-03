task :update_counters => :environment do
  # Update the counters for the locations
  Location.pluck(:id).each { |id| Location.reset_counters(id, :users) }

  # Interest.pluck(:id).each { |id| Interest.reset_counters(id, :users) }

  # Update the counters for the locations
  # Interest.pluck(:id).each { |id| Interest.reset_counters(id, :users) }
end