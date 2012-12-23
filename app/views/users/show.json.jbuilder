unless @user.new_record?
  json.(@user, :id, :uuid)
  json.age age_from_birthday(@user.birthday)
  json.invite_path user_invitation_path(@user.invite_slug)
  json.interests @user.interests
  json.location do
    json.partial! @user.location
  end
end

json.facebook_id @user.facebook_id if @user.facebook?

json.(@user, :email, :first_name, :last_name, :gender, :single, :interested_in, :bio)

json.photo @user.photo