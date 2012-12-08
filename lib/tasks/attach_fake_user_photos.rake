task :attach_fake_user_photos => :environment do
  
  profile_photos_dir = Rails.root.join('tmp', 'profile_photos')
  
  photos = {
    'male' => Dir.glob(profile_photos_dir.join('male/*')),
    'female' => Dir.glob(profile_photos_dir.join('female/*'))
  }

  fake_users = User.where("email ILIKE '%dbld8.com%'")

  fake_users.each_with_index do |user, index|
    user.profile_photos.delete

    photo = UserPhoto.new

    puts "Set photo for #{user}. #{index+1}/#{fake_users.count}"

    photo.user = user
    photo.image = File.open(photos[user.gender].sample)

    photo.save!
  end

end