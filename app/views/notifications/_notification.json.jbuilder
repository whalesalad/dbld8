json.cache! notification do |json|
  json.(notification, :id, :uuid)
  json.notification notification.to_s
  json.push notification.push?
  json.unread notification.unread?
  json.callback notification.callback_str
  json.created_at notification.created_at
end

json.created_at_ago time_ago_in_words(notification.created_at)