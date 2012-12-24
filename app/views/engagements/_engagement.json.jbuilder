json.(engagement, :id, :status, :created_at)

json.created_at_ago time_ago_in_words(engagement.created_at)

json.messages_count engagement.messages.count

json.user do
  json.partial! engagement.user
end

json.wing do
  json.partial! engagement.wing
end