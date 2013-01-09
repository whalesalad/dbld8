class FakePhotoWorker
  include Sidekiq::Worker

  def perform(user_id, photo_path)
    user = User.find(user_id)
    
    user.profile_photos.delete

    photo = UserPhoto.new

    photo.user = user
    photo.image = File.open(photo_path)

    photo.save!
  end
end