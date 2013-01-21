json.(message, :id, :created_at, :user_id)

json.first_name message.user.first_name
json.created_at_ago time_ago_in_words(message.created_at)

json.unread message.unread_for(@authenticated_user)

json.message message.message