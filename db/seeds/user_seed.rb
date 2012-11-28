class UserSeed

  MALE_NAMES = %w(Alex Allen Adam Austin Ben Bill Brian Chad Chris Dan David Kyle 
                  Levi Michael Mike Nate Nick Peter Paul Ryan Sam Tom Ken Brett)

  FEMALE_NAMES = %w(Amanda Ashley Erica Eve Heather Kennedy Elizabeth Mary Rachel Rebecca
                    Sarah Ivy Jamie Jenna Jenny Jessica Jess Julie Melissa Natalie)

  LAST_NAMES = %w(Smith Johnson Williams Jones Brown Wilson Moore Taylor 
                  Anderson Thomas Martin Clark Rodriguez Baker Parker Reed 
                  Morgan Cox Grey Palmer Thompson Harris)

  attr_accessor :interest_ids, :location_ids

  def initialize
    MALE_NAMES.each { |f| seed_user(f, 'male') } 
    FEMALE_NAMES.each { |f| seed_user(f, 'female') }
  end

  def seed_user(first_name, gender)
    last_name = LAST_NAMES.sample

    u = User.create({ 
      first_name: first_name, 
      last_name: last_name,
      email: email_from(first_name, last_name),
      bio: Faker::Lorem.paragraph(2),
      password: 'testing',
      birthday: ages.sample.years.ago,
      location_id: location_ids.sample,
      gender: gender
    })

    # set interests
    u.interests = interests.sample(7)

    u.save!
  end

  def email_from(first_name, last_name)
    "#{first_name.downcase}.#{last_name.downcase}@dbld8.com"
  end

  def ages
    (19..40).to_a
  end

  def location_ids
    Location.cities.pluck(:id)
  end

  def interests
    Interest.all.map do |interest|
      (interest.users.count > 0) ? interest : nil
    end.compact
  end
  
end