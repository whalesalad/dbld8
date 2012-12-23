unless @user.new_record?
  json.id @user.id
  json.age determine_age(@user.birthday)
end

json.facebook_id @user.facebook_id if @user.facebook?

json.(@user, :uuid, :email, :first_name, :last_name, :gender, :single, :interested_in, :bio)

json.photo @user.photo

json.invite_path user_invitation_path(@user.invite_slug)

json.interests @user.interests do |interest|
  json.partial! interest
end

json.location do
  json.partial! @user.location
end