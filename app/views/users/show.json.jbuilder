json.(@user, :id, :uuid, :email, :first_name, :last_name, :gender, 
  :birthday, :age, :single, :interested_in, :bio, :total_coins, :total_karma)

json.facebook_id(@user.facebook_id) if @user.is_a?(FacebookUser)

json.invite_path user_invitation_path(@user.invite_slug)

json.unread_notifications_count @user.unread_notifications_count
json.unread_messages_count @user.unread_messages_count
json.pending_wings_count @user.pending_wings_count
json.badge_count @user.badge_count

if @user.location.present?
  json.location do
    json.partial! @user.location
  end
end

json.photo @user.photo

json.features @user.features

json.partial! "interests/interests", interests: matching_interests_with(@user)