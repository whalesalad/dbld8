json.(engagement, :id, :created_at)

json.created_at_ago time_ago_in_words(engagement.created_at)

json.unlocked engagement.unlocked?

json.messages_count engagement.messages.count

if engagement.messages.first.present?
  json.primary_message engagement.messages.first.body
end

json.user do
  json.partial! 'users/user', user: engagement.user
end

json.wing do
  json.partial! 'users/user', user: engagement.wing
end