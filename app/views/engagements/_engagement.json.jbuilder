json.(engagement, :id, :created_at)

json.created_at_ago time_ago_in_words(engagement.created_at)
json.updated_at engagement.updated_at
json.updated_at_ago time_ago_in_words(engagement.updated_at)

json.activity_id engagement.activity_id
json.activity_title engagement.activity.title

json.status engagement.status
json.unread_count engagement.messages.unread_for(@authenticated_user).count

if engagement.messages.first.present?
  json.primary_message engagement.messages.first.message
end

json.cache! engagement do |json|
  json.user do
    json.partial! 'users/user', user: engagement.user
  end

  json.wing do
    json.partial! 'users/user', user: engagement.wing
  end
end