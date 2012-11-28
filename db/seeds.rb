$LOAD_PATH << File.dirname(__FILE__)

#                        __       __      __        __
#    ________  ___  ____/ /  ____/ /___ _/ /_____ _/ /
#   / ___/ _ \/ _ \/ __  /  / __  / __ `/ __/ __ `/ / 
#  (__  )  __/  __/ /_/ /  / /_/ / /_/ / /_/ /_/ /_/  
# /____/\___/\___/\__,_/   \__,_/\__,_/\__/\__,_(_)   
#
#

# activities
# friendships

# Let's get some initial interests defined here.
interests = [
  'Hiking', 'Camping', 'Running', 'Traveling', 'Surfing', 'Biking', 'Cats',
  'Dogs', 'Coffee', 'Design', 'Off Roading', 'Fishing', 'Dancing', 'Hacking',
  'Clubbing', 'Dubstep', 'Concerts', 'Skiing', 'Eating', 'Food' 
]

puts 'Seeding Interests...'

interests.each { |i| Interest.create(:name => i) }
  
# Let's get some cities and venues...
WASHINGTONDC = [38.8951118, -77.0363658]
OREBRO = [59.2741206163838, 15.2066016197205]
SANTAMONICA = [34.0172423358256, -118.49820792675]
WAIKIKI = [21.2764980618893, -157.827744483948]

puts 'Seeding Locations...'

[WASHINGTONDC, OREBRO, SANTAMONICA, WAIKIKI].each do |lat,lng|
  Location.find_cities_and_venues_near(lat,lng)
end

puts 'Seeding CreditActions...'

credit_actions = {
  'registration' => 1000,
  'activity_create' => -10
}

credit_actions.each do |slug, cost|
  CreditAction.find_or_create_by_slug(:slug => slug, :cost => cost)
end

# do user seeds
require 'seeds/user_seed'

puts 'Seeding Users...'

UserSeed.new()

# connect users - create random friendships.
# for every user, create 3 solidified friendships

puts 'Building random friendships...'

all_users = User.find(:all)

all_users.each do |user|
  user.invite all_users.sample, true
  user.invite all_users.sample, true
  user.invite all_users.sample, false
end
