json.(@user, :id, :uuid)

if @user.is_a?(FacebookUser)
  json.facebook_id @user.facebook_id
end

json.(@user, :email, :first_name, :last_name, :gender, 
  :birthday, :age, :single, :interested_in, :bio, :total_coins, :total_karma)

json.invite_path user_invitation_path(@user.invite_slug)

json.interests @user.interests_matching_with(@authenticated_user) do |interest|
  json.(interest, :id, :name, :matched)
end

if @user.location.present?
  json.location do
    json.partial! @user.location
  end
end

json.photo @user.photo