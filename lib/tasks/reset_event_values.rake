namespace :dbld8 do
  task :reset_event_values => :environment do
    puts "Resetting all user Events coin/karma based on hard-coded values."
    Event.all.each do |event|
      event.reset_initial_values!
    end
  end
end