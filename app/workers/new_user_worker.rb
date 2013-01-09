# When a new user joins...
# 1) send an email to that user welcoming them
# 2) handle any facebook invitations
# 3) create the registration object

class NewUserWorker
  include Sidekiq::Worker

  def perform(new_user_id)
    new_user = User.find(new_user_id)

    # Create the registration action
    new_user.trigger 'registration'
  end
end