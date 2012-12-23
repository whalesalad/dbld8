json.(engagement, :id, :status, :created_at)

json.messages_count engagement.messages.count

json.user do
  json.partial! engagement.user
end

json.wing do
  json.partial! engagement.wing
end