json.(@user, :id, :uuid)

if @user.is_a?(FacebookUser)
  json.facebook_id @user.facebook_id
end

json.(@user, :email, :first_name, :last_name, :gender, 
  :birthday, :age, :single, :interested_in, :bio, :total_coins, :total_karma)

json.unread_notifications_count @user.notifications.events.unread.count
json.unread_messages_count @user.unread_messages.count
json.pending_wings_count @user.pending_friends.count

json.invite_path user_invitation_path(@user.invite_slug)

# json.cache! ['long_user', @user] do |json|
if @user.location.present?
  json.location do
    json.partial! @user.location
  end
end

json.photo @user.photo
# end

json.interests @user.interests_matching_with(@authenticated_user) do |interest|
  json.(interest, :id, :name, :matched)
end