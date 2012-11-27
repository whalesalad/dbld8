#                        __       __      __        __
#    ________  ___  ____/ /  ____/ /___ _/ /_____ _/ /
#   / ___/ _ \/ _ \/ __  /  / __  / __ `/ __/ __ `/ / 
#  (__  )  __/  __/ /_/ /  / /_/ / /_/ / /_/ /_/ /_/  
# /____/\___/\___/\__,_/   \__,_/\__,_/\__/\__,_(_)   
#
#


# interests
# locations
# activities
# users
# friendships

# Let's get some initial interests defined here.
interests = [
  'Hiking', 'Camping', 'Running', 'Traveling', 'Surfing', 'Biking', 'Cats',
  'Dogs', 'Coffee', 'Design', 'Off Roading', 'Fishing', 'Dancing', 'Hacking',
  'Clubbing', 'Dubstep', 'Concerts', 'Skiing', 'Eating', 'Food' 
]

# interests.each { |i| Interest.create(:name => i) }
  
# Let's get some cities and venues...
WASHINGTONDC = [38.8951118, -77.0363658]
OREBRO = [59.2741206163838, 15.2066016197205]
SANTAMONICA = [34.0172423358256, -118.49820792675]
WAIKIKI = [21.2764980618893, -157.827744483948]

[WASHINGTONDC, OREBRO, SANTAMONICA, WAIKIKI].each do |lat,lng|
  # Location.find_cities_and_venues_near(lat,lng)
end

credit_actions = {
  'registration' => 1000,
  'activity_create' => -10
}

credit_actions.each do |slug, cost|
  # CreditAction.create(:slug => slug, :cost => cost)
end


MALE_NAMES = %w(Alex Allen Adam Austin Ben Bill Brian Chad Chris Dan David Kyle 
                Levi Michael Mike Nate Nick Peter Paul Ryan Sam)

FEMALE_NAMES = %w(Amanda Ashley Erica Eve Heather Kennedy Elizabeth Mary Rachel Rebecca
                  Sarah Ivy Jamie Jenna Jenny Jessica Jess Julie Melissa Natalie)

LAST_NAMES = %w(Smith Johnson Williams Jones Brown Wilson Moore Taylor 
                Anderson Thomas Martin Clark Rodriguez Baker Parker Reed 
                Morgan Cox Grey Palmer Thompson Harris)

location_ids = Location.cities.pluck(:id)
ages = (19..45).to_a

interest_ids = []
Interest.all.each do |interest|
  interest_ids << interest.id if interest.users.count > 0
end

MALE_NAMES.each do |first|
  last = LAST_NAMES.sample
  email_prefix = "#{first[0]}#{last}"

  u = User.create({ 
    first_name: first, 
    last_name: last,
    email: "#{email_prefix.downcase}+test@belluba.com",
    bio: Faker::Lorem.sentence(20),
    password: 'testing',
    birthday: ages.sample.years.ago,
    location_id: location_ids.sample,
    interest_ids: interest_ids.sample(7),
    gender: 'male'
  })
end

FEMALE_NAMES.each do |first|
  last = LAST_NAMES.sample
  email_prefix = "#{first[0]}#{last}"

  u = User.create({ 
    first_name: first, 
    last_name: last,
    email: "#{email_prefix.downcase}+test@belluba.com",
    bio: Faker::Lorem.sentence(20),
    password: 'testing',
    birthday: ages.sample.years.ago,
    location_id: location_ids.sample,
    interest_ids: interest_ids.sample(7),
    gender: 'female'
  })
end