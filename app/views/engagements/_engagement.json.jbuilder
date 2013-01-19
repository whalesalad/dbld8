json.(engagement, :id, :created_at)

json.created_at_ago time_ago_in_words(engagement.created_at)

json.messages_count engagement.messages.count
json.primary_message engagement.messages.first.body

json.user do
  json.partial! 'users/user', user: engagement.user
end

json.wing do
  json.partial! 'users/user', user: engagement.wing
end