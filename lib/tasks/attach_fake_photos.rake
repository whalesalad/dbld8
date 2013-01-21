namespace :dbld8 do
  task :attach_fake_photos => :environment do
    
    profile_photos_dir = Rails.root.join('lib', 'profile_photos')
    
    photos = {
      'male' => Dir.glob(profile_photos_dir.join('male/*')),
      'female' => Dir.glob(profile_photos_dir.join('female/*'))
    }

    fake_users = User.where("email ILIKE '%dbld8.com%'")

    fake_users.each_with_index do |user, index|
      puts "Boom! FakePhotoWorker for #{user}. #{index+1}/#{fake_users.count}"
      FakePhotoWorker.perform_async(user.id, photos[user.gender].sample)
    end
    
  end
end