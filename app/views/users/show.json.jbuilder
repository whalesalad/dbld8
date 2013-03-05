json.(@user, :id, :uuid)

if @user.is_a?(FacebookUser)
  json.facebook_id @user.facebook_id
end

json.(@user, :email, :first_name, :last_name, :gender, 
  :birthday, :age, :single, :interested_in, :bio, :total_coins, :total_karma)

json.unread_notifications_count @user.unread_notifications_count
json.unread_messages_count @user.unread_messages_count
json.pending_wings_count @user.pending_wings_count
json.badge_count @user.badge_count

json.invite_path user_invitation_path(@user.invite_slug)

if @user.location.present?
  json.location do
    json.partial! @user.location
  end
end

json.photo @user.photo

json.features @user.features

if @user.interests.any?
  json.interests @user.interests_matching_with(@authenticated_user) do |interest|
    json.(interest, :id, :name, :matched)
  end
end