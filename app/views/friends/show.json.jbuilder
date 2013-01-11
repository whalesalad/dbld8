json.(@friend, :id, :uuid)

if @friend.is_a?(FacebookUser)
  json.facebook_id @user.facebook_id
end

json.(@friend, :email, :first_name, :last_name, :gender, :birthday, :age, :single, :interested_in, :bio, :total_coins, :total_karma)

json.invite_path user_invitation_path(@friend.invite_slug)
json.interests @friend.interests

if @friend.location.present?
  json.location do
    json.partial! @friend.location
  end
end

json.photo @friend.photo