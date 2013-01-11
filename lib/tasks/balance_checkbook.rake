namespace :dbld8 do
  task :balance_checkbook => :environment do
    puts "Resetting all UserAction coin/karma based on hard-coded values."
    UserAction.all.each do |action|
      action.reset_initial_values!
    end
  end
end