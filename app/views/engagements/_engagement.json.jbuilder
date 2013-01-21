json.(engagement, :id, :created_at)

json.created_at_ago time_ago_in_words(engagement.created_at)

json.status engagement.status

json.messages_count engagement.messages.count

if engagement.messages.first.present?
  json.primary_message engagement.messages.first.message
end

json.user do
  json.partial! 'users/user', user: engagement.user
end

json.wing do
  json.partial! 'users/user', user: engagement.wing
end