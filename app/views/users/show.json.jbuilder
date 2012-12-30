unless @user.new_record?
  json.(@user, :id, :uuid)
  json.age @user.age
  json.invite_path user_invitation_path(@user.invite_slug)
  json.interests @user.interests
  if @user.location.present?
    json.location do
      json.partial! @user.location
    end
  end
end

if @user.is_a?(FacebookUser)
  json.facebook_id @user.facebook_id
end

json.(@user, :email, :first_name, :last_name, :gender, :birthday, :single, :interested_in, :bio)

json.photo @user.photo