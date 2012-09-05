# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Let's get some initial interests defined here.
fb_interests = {
  '105525412814559' => 'Hiking',
  '105426616157521' => 'Camping',
  '109368782422374' => 'Running',
  '110534865635330' => 'Traveling',
  '111932052156866' => 'Surfing',
  '106052116101781' => 'Biking',
  '111851445501172' => 'Cats',
  '114197241930754' => 'Dogs',
  '103758506330178' => 'Coffee'
}

fb_interests.each do |fb_id, name|
  Interest.create(facebook_id: fb_id, name: name)
end

misc_interests = [
  'Apple', 'Programming', 'Cave Diving', 'Off Roading', 'Deep-Sea Fishing',
  'Sexting', 'Dancing', 'Clubbing', 'Dubstep', 'Concerts'
]

misc_interests.each do |interest|
  Interest.create(name: interest)
end