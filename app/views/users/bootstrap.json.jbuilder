json.(@user, :email, :first_name, :last_name, :gender, :birthday, :age, :single, :interested_in, :bio)

if @user.is_a?(FacebookUser)
  json.facebook_id @user.facebook_id
end

json.photo @user.photo