unless @user.new_record?
  json.(@user, :id, :uuid)
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

json.(@user, :email, :first_name, :last_name, :gender, :birthday, :age, :single, :interested_in, :bio)

json.(@user, :total_coins, :total_karma)

json.photo @user.photo